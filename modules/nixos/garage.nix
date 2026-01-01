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

  # To enable this service:
  # 1. Generate RPC secret: openssl rand -hex 32
  # 2. Add to secrets.nix under garage.rpc_secret
  # 3. Enable this module in hosts/nas/default.nix
  # 4. Run: sudo nixos-rebuild switch --flake .#nas
  # 5. Initialize cluster:
  #    garage status
  #    garage layout assign <node-id> -c 500G -z default
  #    garage layout apply --version 1
  # 6. Create buckets and keys:
  #    garage bucket create my-bucket
  #    garage key create my-key
  #    garage bucket allow --read --write my-bucket --key my-key

  # Data Migration from MinIO

  # # Configure both endpoints
  # mc alias set minio http://10.0.7.7:9000 <minio-access-key> <minio-secret-key>
  # mc alias set garage http://10.0.7.7:3900 <garage-access-key> <garage-secret-key>

  # # Migrate data
  # mc mirror minio/bucket-name garage/bucket-name

  # Set an expiration policy (using the aws CLI):

  # aws s3api put-bucket-lifecycle-configuration \
  #         --endpoint-url http://127.0.0.1:3900 \
  #         --bucket talos-backup \
  #         --lifecycle-configuration '{
  #       "Rules": [
  #         {
  #           "ID": "30-day-expiration",
  #           "Status": "Enabled",
  #           "Expiration": {
  #             "Days": 30
  #           }
  #         }
  #       ]
  #     }'

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
