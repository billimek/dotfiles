{ ... }: {
  flake.nixosModules.reboot-required =
    # Reboot required check service
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.modules.reboot-required;
    in
    {
      options.modules.reboot-required = {
        enable = lib.mkEnableOption "reboot required check";
      };

      config = lib.mkIf cfg.enable {
        systemd.tmpfiles.rules = [
          "d /var/lib/prometheus-node-exporter-textfile 0755 root root -"
        ];

        systemd.timers."reboot-required-check" = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "0m";
            OnUnitActiveSec = "1h";
            Unit = "reboot-required-check.service";
          };
        };

        systemd.services."reboot-required-check" = {
          script = ''
            #!/usr/bin/env bash

            textfileDir=/var/lib/prometheus-node-exporter-textfile
            metricFile="$textfileDir/reboot_required.prom"

            writeMetric() {
              if [[ -d "$textfileDir" ]]; then
                echo "node_reboot_required $1" > "$metricFile.tmp" && mv "$metricFile.tmp" "$metricFile"
              fi
            }

            if [[ "$(readlink /run/booted-system/{initrd,kernel,kernel-modules})" == "$(readlink /run/current-system/{initrd,kernel,kernel-modules})" ]]; then
              if [[ -f /var/run/reboot-required ]]; then
                rm /var/run/reboot-required || { echo "Failed to remove /var/run/reboot-required"; exit 1; }
              fi
              writeMetric 0
            else
              echo "reboot required"
              touch /var/run/reboot-required || { echo "Failed to create /var/run/reboot-required"; exit 1; }
              writeMetric 1
            fi
          '';
          serviceConfig = {
            Type = "oneshot";
            User = "root";
          };
        };
      };
    };
}
