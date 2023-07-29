{ config, pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.php
    pkgs.php82Packages.composer
  ];

  systemd.timers."oci-arm-host-capacity" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "oci-arm-host-capacity.service";
      };
  };

  systemd.services."oci-arm-host-capacity" = {
    script = ''
      set -eu
      /home/jeff/.nix-profile/bin/php /home/jeff/src/oci-arm-host-capacity/index.php >> /home/jeff/src/oci-arm-host-capacity/oci.log
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "jeff";
    };
  };

}
