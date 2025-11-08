{
  config,
  lib,
  pkgs,
  ...
}:
let
  secrets = import ../../../secrets.nix;
in
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
      rpc_secret = secrets.garage.rpc_secret;

      # S3 API configuration
      s3_api = {
        api_bind_addr = "[::]:3900";
        s3_region = "garage";
      };
    };
  };

  # Create explicit garage user and group (not DynamicUser)
  users = {
    users.garage = {
      isSystemUser = true;
      group = "garage";
    };
    groups.garage = { };
  };

  # Override systemd service to use explicit user and manage directories
  systemd.services.garage = {
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "garage";
      Group = "garage";
    };
  };

  # Preconfigure service to create directories with proper ownership
  systemd.services.garage-preconfigure = {
    requires = [ "mnt-ssdtank.mount" ];
    after = [ "mnt-ssdtank.mount" ];
    requiredBy = [ "garage.service" ];
    before = [ "garage.service" ];
    partOf = [ "garage.service" ];
    bindsTo = [ "garage.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = with pkgs; [
      coreutils
      util-linux
    ];
    script = ''
      set -euo pipefail

      # Create garage directories if they don't exist
      mkdir -p /mnt/ssdtank/garage
      mkdir -p /mnt/ssdtank/garage/data
      mkdir -p /mnt/ssdtank/garage/meta

      # Set ownership
      chown garage:garage /mnt/ssdtank/garage
      chown garage:garage /mnt/ssdtank/garage/data
      chown garage:garage /mnt/ssdtank/garage/meta

      # Set permissions
      chmod 755 /mnt/ssdtank/garage
      chmod 755 /mnt/ssdtank/garage/data
      chmod 755 /mnt/ssdtank/garage/meta
    '';
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
