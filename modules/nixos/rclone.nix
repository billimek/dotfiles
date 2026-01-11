# Rclone backup configuration
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.rclone;
in
{
  options.modules.rclone = {
    enable = lib.mkEnableOption "rclone backup jobs";
  };

  config = lib.mkIf cfg.enable {
    # Generate rclone.conf dynamically using secrets
    systemd.services.generate-rclone-config = {
      description = "Generate rclone configuration with secrets";
      wantedBy = [ "multi-user.target" ];
      after = [ "opnix-secrets.service" ];
      requires = [ "opnix-secrets.service" ];

      serviceConfig = {
        Type = "oneshot";
        User = "root";
        RemainAfterExit = true;
      };

      script = ''
        mkdir -p /home/nix/.config/rclone

        cat > /home/nix/.config/rclone/rclone.conf << EOF
        [garage]
        type = s3
        provider = Other
        access_key_id = $(cat ${config.services.onepassword-secrets.secretPaths.garageS3AccessKey})
        secret_access_key = $(cat ${config.services.onepassword-secrets.secretPaths.garageS3SecretKey})
        endpoint = http://10.0.7.7:3900
        region = garage
        force_path_style = true

        [b2]
        type = b2
        account = $(cat ${config.services.onepassword-secrets.secretPaths.b2AccountId})
        key = $(cat ${config.services.onepassword-secrets.secretPaths.b2ApplicationKey})
        EOF

        chown nix:users /home/nix/.config/rclone/rclone.conf
        chmod 0600 /home/nix/.config/rclone/rclone.conf
      '';
    };

    systemd.services.generate-rclone-config.serviceConfig.ExecStartPost = [
      "${pkgs.systemd}/bin/systemctl try-restart rclone-backup-postgres.service"
      "${pkgs.systemd}/bin/systemctl try-restart rclone-backup-kopia.service"
    ];

    systemd.services."rclone-backup-postgres" = {
      description = "Rclone backup postgres";
      script = ''
        ${pkgs.rclone}/bin/rclone --config /home/nix/.config/rclone/rclone.conf --transfers 50 --fast-list sync garage:postgresql b2:billimek-postgres
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };

    systemd.timers."rclone-backup-postgres" = {
      description = "Rclone backup timer postgres";
      timerConfig = {
        OnCalendar = "6:00:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };

    systemd.services."rclone-backup-kopia" = {
      description = "Rclone backup kopia to B2";
      script = ''
        # Find the most recent daily snapshot
        LATEST_SNAPSHOT=$(${pkgs.zfs}/bin/zfs list -H -t snapshot -o name -s creation ssdtank/kopia | ${pkgs.gnugrep}/bin/grep '@autosnap_.*_daily' | tail -1)

        if [ -z "$LATEST_SNAPSHOT" ]; then
          echo "ERROR: No daily snapshot found for ssdtank/kopia"
          exit 1
        fi

        SNAPSHOT_PATH="/mnt/$LATEST_SNAPSHOT"
        echo "Syncing from snapshot: $SNAPSHOT_PATH"

        ${pkgs.rclone}/bin/rclone --config /home/nix/.config/rclone/rclone.conf \
          --transfers 50 \
          --fast-list \
          sync "$SNAPSHOT_PATH" b2:billimek-kopia
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      after = [ "generate-rclone-config.service" ];
      requires = [ "generate-rclone-config.service" ];
    };

    systemd.timers."rclone-backup-kopia" = {
      description = "Rclone backup timer for kopia";
      timerConfig = {
        OnCalendar = "5:00:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
