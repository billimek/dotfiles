# X11 utilities (for X forwarding)
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.x11;
in
{
  options.modules.x11 = {
    enable = lib.mkEnableOption "X11 utilities" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.xorg.xauth ];
  };
}
