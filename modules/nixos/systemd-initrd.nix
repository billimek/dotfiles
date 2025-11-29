# Systemd initrd support
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.systemd-initrd;
in
{
  options.modules.systemd-initrd = {
    enable = lib.mkEnableOption "systemd initrd" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.systemd.enable = true;
  };
}
