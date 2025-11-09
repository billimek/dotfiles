{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Garage S3-compatible object storage
  # Documentation: https://garagehq.deuxfleurs.fr/
  #
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

  services.garage = {
    enable = true;
    package = pkgs.garage_2;

    settings = {
      # Storage locations - both on ZFS pool for durability
      metadata_dir = "/mnt/ssdtank/garage/meta";
      data_dir = "/mnt/ssdtank/garage/data";

      replication_factor = 1;

      # RPC configuration (internal cluster communication)
      rpc_bind_addr = "[::]:3901";
      # Use opnix-managed secret file
      rpc_secret_file = config.services.onepassword-secrets.secretPaths.garageRpcSecret;

      # S3 API configuration
      s3_api = {
        api_bind_addr = "[::]:3900";
        s3_region = "garage";
      };
    };
  };

  # Create explicit garage user and group (not DynamicUser)
  # Add nix user to garage group for CLI access to secrets
  users = {
    users.garage = {
      isSystemUser = true;
      group = "garage";
    };
    users.nix.extraGroups = [ "garage" ];
    groups.garage = { };
  };

  # Use systemd.tmpfiles for directory management
  systemd.tmpfiles.rules = [
    # Create garage subdirectories with proper ownership and permissions
    "d /mnt/ssdtank/garage/data 0755 garage garage -"
    "d /mnt/ssdtank/garage/meta 0755 garage garage -"
  ];

  # Ensure garage service waits for ZFS dataset mount and OpNix secrets
  # OpNix will handle service dependencies automatically via the services = ["garage"] config
  systemd.services.garage = {
    requires = [ "mnt-ssdtank-garage.mount" "opnix-secrets.service" ];
    after = [ "mnt-ssdtank-garage.mount" "opnix-secrets.service" ];
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "garage";
      Group = "garage";
      # Allow group-readable secrets so nix user can access them for CLI
      Environment = [ "GARAGE_ALLOW_WORLD_READABLE_SECRETS=true" ];
    };
  };

  # Optional Garage Web UI
  # Provides a web-based management UI for the Garage service.
  # This creates a simple systemd service that runs the `garage-webui` binary
  # from the `garage-webui` package and serves on TCP/3909 by default.
  systemd.services.garage-webui = {
    # disabled until this works properly with garage2
    enable = false;
    description = "Garage Web UI";
    after = [
      "network.target"
      "garage.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "garage";
      Group = "garage";
      Environment = [
        "CONFIG_PATH=/etc/garage.toml"
      ];
      ExecStart = "${pkgs.garage-webui}/bin/garage-webui";
      Restart = "on-failure";
    };
    path = with pkgs; [ coreutils ];
  };

  # Open firewall ports for Garage S3 API and the Web UI
  networking.firewall.allowedTCPPorts = [
    3900 # S3 API (default)
    3909 # Garage Web UI
  ];

  # Add garage CLI and Web UI to system packages for management
  environment.systemPackages = with pkgs; [
    garage_2
    garage-webui
  ];
}
