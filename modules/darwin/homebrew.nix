# Homebrew package management
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.homebrew;
in
{
  options.modules.homebrew = {
    enable = lib.mkEnableOption "homebrew package management" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      onActivation.autoUpdate = true;
      onActivation.upgrade = true;
      onActivation.cleanup = "zap";
      brews = [ "cask" ];
      casks = [
        "1password"
        "1password-cli"
        "discord"
        "element"
        "ghostty"
        "iterm2"
        # "itermbrowserplugin"
        # "karabiner-elements"
        "notunes"
        "orion"
        "spotify"
        "shottr"
        "visual-studio-code"
        "visual-studio-code@insiders"
        "vlc"
      ];
      masApps = {
        "1Password for Safari" = 1569813296;
        "Tailscale" = 1475387142;
        "consent-o-matic" = 1606897889;
        "Kagi Search for Safari" = 1622835804;
        "Wipr2 for Safari" = 1662217862;
        "MuteKey" = 1509590766;
      };
    };
  };
}
