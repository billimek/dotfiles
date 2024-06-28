{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    ipmitool
    lm_sensors
  ];
  networking.firewall.allowedTCPPorts = [
    config.services.prometheus.exporters.ipmi.port
    config.services.prometheus.exporters.minio.port
    config.services.prometheus.exporters.node.port
    config.services.prometheus.exporters.smartctl.port
    config.services.prometheus.exporters.zfs.port
  ];
  services.prometheus = {
    exporters = {
      ipmi = {
        enable = true;
        port = 9290;
        user = "root";
        group = "root";
      };
      minio = {
        enable = true;
        port = 9291;
      };
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        disabledCollectors = [ "textfile" ];
        port = 9100;
      };
      smartctl = {
        enable = true;
        port = 9633;
      };
      zfs = {
        enable = true;
        port = 9134;
      };
    };
  };
}
