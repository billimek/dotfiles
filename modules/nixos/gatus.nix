# Gatus uptime monitoring and status page
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.gatus;

  configYaml = ''
    web:
      port: ${toString cfg.port}

    storage:
      type: sqlite
      path: /var/lib/gatus/gatus.db
      caching: true

    connectivity:
      checker:
        target: 1.1.1.1:53
        interval: 1m

    alerting:
      discord:
        webhook-url: "''${DISCORD_WEBHOOK_URL}"
        default-alert:
          enabled: true
          failure-threshold: 3
          success-threshold: 2
          send-on-resolved: true
      ntfy:
        topic: "eviljungle-gatus"
        url: "https://ntfy.sh"
        token: "''${NTFY_ACCESS_TOKEN}"
        priority: 4
        click: "https://cloud.drake-eel.ts.net"
        default-alert:
          enabled: true
          failure-threshold: 3
          success-threshold: 2
          send-on-resolved: true

    ui:
      title: "External Status | eviljungle.com"
      header: "eviljungle.com External Monitoring"
      dashboard-heading: ""
      dashboard-subheading: ""
      logo: https://avatars.githubusercontent.com/u/6393612
      link: https://github.com/billimek
      buttons:
        - name: Homelab
          link: https://github.com/billimek/k8s-gitops
        - name: Internal Status
          link: https://status.eviljungle.com

    metrics: true

    endpoints:
      - name: DNS eviljungle.com
        group: external
        url: 1.1.1.1
        interval: 5m
        dns:
          query-name: eviljungle.com
          query-type: A
        conditions:
          - "[DNS_RCODE] == NOERROR"

      - name: Audiobookshelf
        group: external
        url: https://abs.eviljungle.com
        interval: 2m
        client:
          dns-resolver: "udp://1.1.1.1:53"
        conditions:
          - "[STATUS] == 200"
          - "[RESPONSE_TIME] < 5000"
          - "[CERTIFICATE_EXPIRATION] > 48h"
        alerts:
          - type: discord

      - name: Home Assistant
        group: external
        url: https://hass.eviljungle.com
        interval: 2m
        client:
          dns-resolver: "udp://1.1.1.1:53"
        conditions:
          - "[STATUS] == any(200, 401)"
          - "[RESPONSE_TIME] < 5000"
          - "[CERTIFICATE_EXPIRATION] > 48h"
        alerts:
          - type: discord

      - name: Matrix
        group: external
        url: https://matrix.eviljungle.com
        interval: 2m
        client:
          dns-resolver: "udp://1.1.1.1:53"
        conditions:
          - "[STATUS] == any(200, 404)"
          - "[RESPONSE_TIME] < 5000"
          - "[CERTIFICATE_EXPIRATION] > 48h"
        alerts:
          - type: discord

      - name: Plex
        group: external
        url: https://plex.eviljungle.com
        interval: 2m
        client:
          dns-resolver: "udp://1.1.1.1:53"
        conditions:
          - "[STATUS] == any(200, 401)"
          - "[RESPONSE_TIME] < 5000"
          - "[CERTIFICATE_EXPIRATION] > 48h"
        alerts:
          - type: discord

      - name: Seerr
        group: external
        url: https://request.eviljungle.com
        interval: 2m
        client:
          dns-resolver: "udp://1.1.1.1:53"
        conditions:
          - "[STATUS] == 200"
          - "[RESPONSE_TIME] < 5000"
          - "[CERTIFICATE_EXPIRATION] > 48h"
        alerts:
          - type: discord

      - name: Internal Gatus
        group: external
        url: https://status.eviljungle.com
        interval: 2m
        client:
          dns-resolver: "udp://1.1.1.1:53"
        conditions:
          - "[STATUS] == 200"
          - "[RESPONSE_TIME] < 5000"
          - "[CERTIFICATE_EXPIRATION] > 48h"
        alerts:
          - type: discord
          - type: ntfy

      - name: OPNsense
        group: external
        url: icmp://direct.eviljungle.com
        interval: 1m
        conditions:
          - "[CONNECTED] == true"
        alerts:
          - type: discord
          - type: ntfy

      - name: qBittorrent
        group: external
        url: tcp://direct.eviljungle.com:50413
        interval: 2m
        conditions:
          - "[CONNECTED] == true"
        alerts:
          - type: discord
  '';

  gatusConfig = pkgs.writeText "gatus-config.yaml" configYaml;

  # Wrapper that loads secrets from opnix into the environment, then exec's
  # gatus. Gatus natively substitutes ${ENV_VAR} in its config file, so
  # secret values never touch the Nix store.
  gatusWrapper = pkgs.writeShellScript "gatus-wrapper.sh" ''
    export DISCORD_WEBHOOK_URL=$(cat ${config.services.onepassword-secrets.secretPaths.gatusDiscordWebhookUrl})
    export NTFY_ACCESS_TOKEN=$(cat ${config.services.onepassword-secrets.secretPaths.gatusNtfyAccessToken})
    exec ${pkgs.gatus}/bin/gatus
  '';
in
{
  options.modules.gatus = {
    enable = lib.mkEnableOption "gatus uptime monitoring";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port for the Gatus web UI and API";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.gatus = {
      isSystemUser = true;
      group = "gatus";
      home = "/var/lib/gatus";
      createHome = true;
    };
    users.groups.gatus = { };

    # Gatus owns its own opnix secret definitions
    services.onepassword-secrets.secrets.gatusDiscordWebhookUrl = {
      reference = "op://nix/discord/gatus-webhook-url";
      owner = "gatus";
      group = "gatus";
      mode = "0640";
    };
    services.onepassword-secrets.secrets.gatusNtfyAccessToken = {
      reference = "op://nix/ntfy/access-token";
      owner = "gatus";
      group = "gatus";
      mode = "0640";
    };

    # Expose Gatus via Tailscale Funnel so external services (e.g. k8s cluster
    # pods that are not on the tailnet) can reach the API.
    # `tailscale funnel --bg` persists the funnel config in tailscaled state,
    # so this only needs to run once after tailscaled starts.
    systemd.services.gatus-funnel = {
      description = "Configure Tailscale Funnel for Gatus";
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
        ExecStart = "${pkgs.tailscale}/bin/tailscale funnel --bg ${toString cfg.port}";
      };
    };

    systemd.services.gatus = {
      description = "Gatus uptime monitoring";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network-online.target"
        "opnix-secrets.service"
      ];
      requires = [ "opnix-secrets.service" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "simple";
        User = "gatus";
        Group = "gatus";
        WorkingDirectory = "/var/lib/gatus";
        StateDirectory = "gatus";
        ExecStart = "${gatusWrapper}";
        Restart = "on-failure";
        RestartSec = "10s";

        # Hardening
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ "/var/lib/gatus" ];
        PrivateTmp = true;
        NoNewPrivileges = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;

        # ICMP checks need raw sockets
        AmbientCapabilities = [ "CAP_NET_RAW" ];
        CapabilityBoundingSet = [ "CAP_NET_RAW" ];
      };

      environment = {
        GATUS_CONFIG_PATH = "${gatusConfig}";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
