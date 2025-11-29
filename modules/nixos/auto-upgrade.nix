# Automatic system upgrades
{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.modules.auto-upgrade;
  # Only enable auto upgrade if current config came from a clean tree
  isClean = inputs.self ? rev;
in
{
  options.modules.auto-upgrade = {
    enable = lib.mkEnableOption "automatic system upgrades" // {
      default = false; # Opt-in feature
    };
  };

  config = lib.mkIf cfg.enable {
    system.autoUpgrade = {
      enable = isClean;
      dates = "hourly";
      flags = [ "--refresh" ];
      flake = "github:billimek/dotfiles";
    };
  };
}
