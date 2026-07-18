{ ... }:
{
  flake.darwinModules.homebrew =
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
        environment.variables.HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS = "1";

        homebrew = {
          enable = true;
          onActivation.autoUpdate = true;
          onActivation.upgrade = false;
          onActivation.cleanup = "uninstall";
          onActivation.extraFlags = [ "--force" ];
          global.brewfile = true;
          brews = [
            "mas"
          ];
          casks = [
            "1password"
            "claude"
            "discord"
            "element"
            "ghostty"
            # "itermbrowserplugin"
            # "karabiner-elements"
            "logi-options+"
            "notunes"
            "orion"
            "spotify"
            "shottr"
            "visual-studio-code"
            "vlc"
          ];
          masApps = {
            "1Password for Safari" = 1569813296;
            "Tailscale" = 1475387142;
            "consent-o-matic" = 1606897889;
            "Kagi Search for Safari" = 1622835804;
            "Wipr2 for Safari" = 1662217862;
          };
        };
      };
    };
}
