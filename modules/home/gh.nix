# GitHub CLI
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.gh;
in
{
  options.modules.gh = {
    enable = lib.mkEnableOption "GitHub CLI" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.gh = {
      enable = true;
      extensions = with pkgs.unstable; [ gh-copilot ];
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
  };
}
