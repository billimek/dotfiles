{ config, pkgs, ... }:
{
  # adopting automation from https://github.com/hitrov/oci-arm-host-capacity
  environment.systemPackages = [
    pkgs.php
    pkgs.php82Packages.composer
  ];

  systemd.timers."oci-arm-host-capacity" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = "1m";
        Unit = "oci-arm-host-capacity.service";
      };
  };

  systemd.services."oci-arm-host-capacity" = {
    script = ''
      /run/current-system/sw/bin/php /home/jeff/src/oci-arm-host-capacity/index.php >> /home/jeff/src/oci-arm-host-capacity/oci.log
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "jeff";
      WorkingDirectory = "/home/jeff/src/oci-arm-host-capacity/";
    };
  };

}
