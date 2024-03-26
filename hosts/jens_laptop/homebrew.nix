{ config, pkgs, ... }: {
  #homebrew packages
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.cleanup = "zap";
    brews = [ "cask" ];
    taps = [ "homebrew/bundle" "homebrew/cask-fonts" "homebrew/services" ];
    casks = [
      "1password"
      "1password-cli" # need to install CLI via brew too to make biometric unlock work with GUI app
      "betterzip" # zip/unzip for quicklook
      "discord"
      "iterm2"
      "microsoft-remote-desktop"
      "obs"
      "qlmarkdown" # markdown preview in quicklook
      "slack"
      "spotify"
      "shottr" # screenshot tool
      "vlc" # video player
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
