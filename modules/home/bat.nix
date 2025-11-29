# Bat - cat with syntax highlighting
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.bat;
in
{
  options.modules.bat = {
    enable = lib.mkEnableOption "bat" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.bat = {
      enable = true;
      config.theme = "Dracula";
    };
  };
}
