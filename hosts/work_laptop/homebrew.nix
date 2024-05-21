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
      "arc"
      "betterzip" # zip/unzip for quicklook
      "discord"
      "gather"
      "microsoft-remote-desktop"
      "notunes" # disable iTunes auto-launch
      "obs"
      "obsidian" # note taking app
      "plex"
      "qlmarkdown" # markdown preview in quicklook
      "rectangle" # window manager
      "spotify"
      "shottr" # screenshot tool
      "VIA"
      "vlc" # video player
    ];
    masApps = {
      "1Password for Safari" = 1569813296;
      "Tailscale" = 1475387142;
      "consent-o-matic" = 1606897889;
      "Kagi Search for Safari" = 1622835804;
      "Wipr for Safari" = 1320666476;
    };
  };
}
