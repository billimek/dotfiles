{ ... }:
{
  flake.nixosModules.ncps =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.modules.ncps;
      secretPaths = config.services.onepassword-secrets.secretPaths;
      upstream = "http://${config.services.ncps.server.addr}";
    in
    {
      options.modules.ncps = {
        enable = lib.mkEnableOption "ncps Nix binary cache (read-only public, authenticated uploads)";
        hostName = lib.mkOption {
          type = lib.types.str;
          example = "nixcache.example.com";
          description = "Cache name ncps uses for its signing key identity.";
        };
        maxSize = lib.mkOption {
          type = lib.types.str;
          default = "100G";
          description = "Maximum size of the cache before the nightly LRU cleanup removes entries.";
        };
        funnelPort = lib.mkOption {
          type = lib.types.port;
          default = 8443;
          description = "Public HTTPS port on the Tailscale Funnel (443, 8443 or 10000).";
        };
        proxyPort = lib.mkOption {
          type = lib.types.port;
          default = 8502;
          description = "Local port nginx listens on for the Funnel.";
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = config.modules.opnix.enable;
            message = "modules.ncps requires modules.opnix.enable = true";
          }
        ];

        services.ncps = {
          enable = true;
          prometheus.enable = false;
          server.addr = "127.0.0.1:8501";
          cache = {
            inherit (cfg) hostName maxSize;
            storage.local = "/var/lib/ncps";
            tempPath = "/var/lib/ncps/tmp";
            databaseURL = "sqlite:/var/lib/ncps/db/db.sqlite";
            lru.schedule = "0 5 * * *";
            allowPutVerb = true;
            allowDeleteVerb = false;
            secretKeyPath = secretPaths.ncpsSigningKey;
            upstream = {
              urls = [ "https://cache.nixos.org" ];
              publicKeys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
            };
          };
        };

        services.nginx = {
          enable = true;
          virtualHosts.${cfg.hostName} = {
            listen = [
              {
                addr = "127.0.0.1";
                port = cfg.proxyPort;
              }
            ];
            extraConfig = ''
              client_max_body_size 4g;
            '';
            # Uploads: ncps serves PUT only under /upload; require basic auth there.
            locations."/upload/" = {
              proxyPass = upstream;
              extraConfig = ''
                auth_basic "ncps upload";
                auth_basic_user_file ${secretPaths.ncpsUploadAuth};
                proxy_request_buffering off;
                proxy_read_timeout 600s;
              '';
            };
            # Everything else is read-only.
            locations."/" = {
              proxyPass = upstream;
              extraConfig = ''
                limit_except GET HEAD {
                  deny all;
                }
              '';
            };
          };
        };

        systemd.services.ncps-funnel = {
          description = "Configure Tailscale Funnel for ncps";
          wantedBy = [ "multi-user.target" ];
          after = [
            "tailscaled.service"
            "network-online.target"
          ];
          requires = [ "tailscaled.service" ];
          wants = [ "network-online.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.tailscale}/bin/tailscale funnel --bg --https=${toString cfg.funnelPort} http://127.0.0.1:${toString cfg.proxyPort}";
          };
        };
      };
    };
}
