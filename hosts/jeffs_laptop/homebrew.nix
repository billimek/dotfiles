{ config, pkgs, ... }: {
  #homebrew packages
  homebrew = {
    casks = [
      "battle-net" # Blizzard launcher
      "google-chrome"
      "discord"
      "microsoft-office"
      "microsoft-remote-desktop"
      "moonlight"
      "mudlet" # MUD client
      "obs"
      "OrbStack"
      "plex"
      "slack"
      "steam"
      "VIA"
      "visual-studio-code"
      "wowup" # WoW addon manager
      "XQuartz" # X11 for macOS
      "zoom"
    ];
    masApps = {
    };
  };
}
