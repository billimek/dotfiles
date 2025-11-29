# Direnv for per-directory environments
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.direnv;
in
{
  options.modules.direnv = {
    enable = lib.mkEnableOption "direnv" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
