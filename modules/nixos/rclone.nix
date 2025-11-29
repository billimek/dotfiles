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
      "${pkgs.systemd}/bin/systemctl try-restart rclone-backup-volsync.service"
      "${pkgs.systemd}/bin/systemctl try-restart rclone-backup-postgres.service"
    ];

    systemd.services."rclone-backup-volsync" = {
      description = "Rclone backup volsync";
      script = ''
        ${pkgs.rclone}/bin/rclone --config /home/nix/.config/rclone/rclone.conf --transfers 50 --fast-list sync garage:volsync b2:billimek-volsync
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };

    systemd.timers."rclone-backup-volsync" = {
      description = "Rclone backup timer volsync";
      timerConfig = {
        OnCalendar = "4:00:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };

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
  };
}
