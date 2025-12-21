# Development tools
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.dev;
in {
  options.modules.dev = {
    enable = lib.mkEnableOption "development tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      python311Packages.pyyaml
      # manage outside of nix until it updates less frequently
      # pkgs.unstable.opencode
      uv
    ];
    home.sessionPath = ["$HOME/.cargo/bin"];
  };
}
