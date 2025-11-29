# Tealdeer - fast tldr client
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.tealdeer;
in
{
  options.modules.tealdeer = {
    enable = lib.mkEnableOption "tealdeer" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.tealdeer = {
      enable = true;
      settings = {
        updates = {
          auto_update = true;
        };
      };
    };
  };
}
