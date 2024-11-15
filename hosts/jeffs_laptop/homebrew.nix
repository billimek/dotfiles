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
      "vmware-fusion"
      "zoom"
    ];
    masApps = {
      "SteamLink" = 1246969117;
    };
  };
}
