# Oracle Cloud ARM host capacity automation
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.oracle-cloud;
in
{
  options.modules.oracle-cloud = {
    enable = lib.mkEnableOption "Oracle Cloud ARM automation";
  };

  config = lib.mkIf cfg.enable {
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
        /run/current-system/sw/bin/php /home/jeff/src/oci-arm-host-capacity/index.php >> /home/jeff/src/oci-arm-host-capacity/oci.log
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "jeff";
        WorkingDirectory = "/home/jeff/src/oci-arm-host-capacity/";
      };
    };
  };
}
