{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    ipmitool
    lm_sensors
  ];
  networking.firewall.allowedTCPPorts = [
    config.services.prometheus.exporters.node.port
    config.services.prometheus.exporters.zfs.port
    config.services.prometheus.exporters.smartctl.port
    config.services.prometheus.exporters.ipmi.port
  ];
  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd"];
        disabledCollectors = ["textfile"];
        port = 9001;
      };
      zfs = {
        enable = true;
        port = 9002;
      };
      smartctl = {
        enable = true;
        port = 9003;
      };
      ipmi = {
        enable = true;
        port = 9004;
      };
    };
  };
}
