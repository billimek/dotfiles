{ config, pkgs, ... }:

{
  #homebrew packages
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.cleanup = "zap";
    brews = [
      "cask"
    ];
    taps = [
      "homebrew/bundle"
      "homebrew/cask-fonts"
      "homebrew/services"
    ];
    casks = [
      "1password"
      "1password-cli" # need to install CLI via brew too to make biometric unlock work with GUI app 
      "discord"
      # "google-chrome"
      "iterm2"
      "flameshot"
      "karabiner-elements"
      "microsoft-remote-desktop"
      "moonlight"
      "obs"
      "plex"
      "slack"
      "spotify"
      "steam"
      "VIA"
      "visual-studio-code"
      "webex"
      "zoom"
    ];
    masApps = {
      "1Password for Safari" = 1569813296;
      Tailscale = 1475387142;
    };
  };
}
