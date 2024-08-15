{ config, pkgs, ... }:
{
  #homebrew packages
  homebrew = {
    casks = [
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
      "wowup" # WoW addon manager
      "XQuartz" # X11 for macOS
      "zoom"
    ];
    masApps = {
      "SteamLink" = 1246969117;
    };
  };
}
