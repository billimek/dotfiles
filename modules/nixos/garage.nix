# Garage S3-compatible object storage
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.garage;
in {
  options.modules.garage = {
    enable = lib.mkEnableOption "garage object storage";
  };

  config = lib.mkIf cfg.enable {
    services.garage = {
      enable = true;
      package = pkgs.garage_2;

      settings = {
        metadata_dir = "/mnt/ssdtank/garage/meta";
        data_dir = "/mnt/ssdtank/garage/data";
        replication_factor = 1;
        rpc_bind_addr = "[::]:3901";
        rpc_public_addr = "localhost:3901";
        rpc_secret_file = config.services.onepassword-secrets.secretPaths.garageRpcSecret;

        s3_api = {
          api_bind_addr = "[::]:3900";
          s3_region = "garage";
        };
        admin = {
          api_bind_addr = "[::]:3903";
          admin_token_file = config.services.onepassword-secrets.secretPaths.garageAdminToken;
        };
      };
    };

    users = {
      users.garage = {
        isSystemUser = true;
        group = "garage";
      };
      users.nix.extraGroups = ["garage"];
      groups.garage = {};
    };

    systemd.tmpfiles.rules = [
      "d /mnt/ssdtank/garage/data 0755 garage garage -"
      "d /mnt/ssdtank/garage/meta 0755 garage garage -"
    ];

    systemd.services.garage = {
      requires = [
        "mnt-ssdtank-garage.mount"
        "opnix-secrets.service"
      ];
      after = [
        "mnt-ssdtank-garage.mount"
        "opnix-secrets.service"
      ];
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "garage";
        Group = "garage";
        Environment = ["GARAGE_ALLOW_WORLD_READABLE_SECRETS=true"];
      };
    };

    systemd.services.garage-webui = {
      enable = true;
      description = "Garage Web UI";
      after = [
        "network.target"
        "garage.service"
      ];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        User = "garage";
        Group = "garage";
        Environment = [
          # cannot reference garage config file directly because it has references to files with secrets and garage-webui doesn't handle secret files at the moment: https://github.com/khairul169/garage-webui/issues/18
          # "CONFIG_PATH=/etc/garage.toml"
          "API_BASE_URL=http://localhost:3903"
          "S3_ENDPOINT_URL=http://localhost:3900"
        ];
        # janky way to set the admin key
        ExecStart = "${pkgs.writeShellScript "garage-webui-wrapper" ''
          export API_ADMIN_KEY=$(cat ${config.services.onepassword-secrets.secretPaths.garageAdminToken})
            exec ${pkgs.garage-webui}/bin/garage-webui
        ''}";
        Restart = "on-failure";
      };
      path = with pkgs; [coreutils];
    };

    networking.firewall.allowedTCPPorts = [
      3900
      3909
    ];

    environment.systemPackages = with pkgs; [
      garage_2
      garage-webui
    ];
  };
}
