{ config, pkgs, ... }:
{
  systemd.timers."reboot-required-check" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "reboot-required-check.service";
      };
  };

  systemd.services."reboot-required-check" = {
    script = ''
      #!/usr/bin/env bash

      # compare current system with booted sysetm to determine if a reboot is required
      if [[ $(readlink /run/booted-system/{initrd,kernel,kernel-modules})" == "$(readlink /run/current-system/{initrd,kernel,kernel-modules})" ]]; then
              echo "no reboot required"
              rm /var/run/reboot-required
      else
              echo "reboot requierd"
              touch /var/run/reboot-required
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
