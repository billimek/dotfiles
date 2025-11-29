# Zoxide - smart cd
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.zoxide;
in
{
  options.modules.zoxide = {
    enable = lib.mkEnableOption "zoxide" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
    };
  };
}
