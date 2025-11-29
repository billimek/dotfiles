# Atuin - shell history sync
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.atuin;
in
{
  options.modules.atuin = {
    enable = lib.mkEnableOption "atuin" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      package = pkgs.unstable.atuin;
      flags = [ "--disable-up-arrow" ];
      settings = {
        auto_sync = true;
        sync_frequency = "1h";
        search_mode = "fuzzy";
        sync.records = true;
      };
    };
  };
}
