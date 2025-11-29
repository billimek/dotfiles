# QEMU guest agent
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.qemu;
in
{
  options.modules.qemu = {
    enable = lib.mkEnableOption "QEMU guest agent";
  };

  config = lib.mkIf cfg.enable {
    services.qemuGuest.enable = true;
  };
}
