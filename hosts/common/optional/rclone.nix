{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ];

  # TODO: handle config/secrets via opnix

  # Automated rclone sync to b2
  # Uses existing /home/nix/.config/rclone/rclone.conf with garage S3 remote configured

  # volsync - sync from garage S3 API instead of deprecated minio filesystem paths
  systemd.services."rclone-backup-volsync" = {
    description = "Rclone backup volsync";
    script = ''
      # Sync from garage S3 API (bucket-to-bucket) instead of filesystem paths
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

  # postgres - sync from garage S3 API instead of deprecated minio filesystem paths
  systemd.services."rclone-backup-postgres" = {
    description = "Rclone backup postgres";
    script = ''
      # Sync from garage S3 API (bucket-to-bucket) instead of filesystem paths
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

  # talos-backup - sync from garage S3 API instead of deprecated minio filesystem paths
  # systemd.services."rclone-backup-talos" = {
  #   description = "Rclone backup talos";
  #   script = ''
  #     # Sync from garage S3 API (bucket-to-bucket) instead of filesystem paths
  #     ${pkgs.rclone}/bin/rclone --config /home/nix/.config/rclone/rclone.conf --transfers 50 --fast-list sync garage:talos-backup b2:billimek-talos-backup
  #   '';
  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "root";
  #   };
  # };
  # systemd.timers."rclone-backup-talos" = {
  #   description = "Rclone backup timer talos";
  #   timerConfig = {
  #     OnCalendar = "8:00:00";
  #     Persistent = true;
  #   };
  #   wantedBy = [ "timers.target" ];
  # };
}
