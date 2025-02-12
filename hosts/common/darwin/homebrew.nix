{ config, pkgs, ... }:
{
  #homebrew packages
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.cleanup = "zap";
    brews = [ "cask" ];
    taps = [
      "homebrew/bundle"
      "homebrew/cask-fonts"
      "homebrew/services"
    ];
    casks = [
      "1password"
      "1password-cli" # need to install CLI via brew too to make biometric unlock work with GUI app
      "betterzip" # zip/unzip for quicklook
      "discord" # chat
      "ghostty" # so hot right now
      "iterm2" # terminal
      "karabiner-elements" # keyboard remapping
      "notunes" # disable iTunes auto-launch
      "orion" # browser
      "qlmarkdown" # markdown preview in quicklook
      "sanesidebuttons" # enable side buttons on mouse
      "spotify" # music
      "shottr" # screenshot tool
      "visual-studio-code" # code editor
      "visual-studio-code@insiders" # code editor
      "vlc" # video player
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
}
