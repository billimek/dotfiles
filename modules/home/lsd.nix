# LSD - modern ls replacement
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.lsd;
in
{
  options.modules.lsd = {
    enable = lib.mkEnableOption "lsd" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.lsd = {
      enable = true;
      settings = {
        date = "+%e %b %H:%M";
        sorting.dir-grouping = "first";
      };
    };
  };
}
