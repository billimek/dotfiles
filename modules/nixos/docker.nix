# Docker container runtime
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.docker;
in
{
  options.modules.docker = {
    enable = lib.mkEnableOption "docker";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
    };

    # Don't wait for network-online.target - just need basic network.target
    systemd.services.docker.after = [ "network.target" ];
    systemd.services.docker.wants = [ "network.target" ];
  };
}
