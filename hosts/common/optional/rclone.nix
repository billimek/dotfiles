{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [];

  # Automated rclone sync to b2

  # TODO: handle config/secrets via nix

  # volsync
  systemd.services."rclone-backup-volsync" = {
    description = "Rclone backup volsync";
    script = ''
      # rclone should use /home/nix/.config/rclone/rclone.conf by default
      ${pkgs.rclone}/bin/rclone --config /home/nix/.config/rclone/rclone.conf --transfers 50 --fast-list sync /mnt/ssdtank/s3/volsync b2:billimek-volsync
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
    wantedBy = ["timers.target"];
  };

  # postgres
  systemd.services."rclone-backup-postgres" = {
    description = "Rclone backup postgres";
    script = ''
      # rclone should use /home/nix/.config/rclone/rclone.conf by default
      ${pkgs.rclone}/bin/rclone --config /home/nix/.config/rclone/rclone.conf --transfers 50 --fast-list sync /mnt/ssdtank/s3/postgresql b2:billimek-postgres
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
    wantedBy = ["timers.target"];
  };
}
