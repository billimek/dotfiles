{
  config,
  pkgs,
  ...
}: {
  #homebrew packages
  homebrew = {
    casks = [
      "google-chrome"
      "discord"
      "freelens"
      "microsoft-office"
      "microsoft-remote-desktop"
      "moonlight"
      "mudlet" # MUD client
      "obs"
      "OrbStack"
      "plex"
      "prismlauncher" # app launcher
      "slack"
      "steam"
      "VIA"
      "vmware-fusion"
      "zoom"
    ];
    masApps = {
      "SteamLink" = 1246969117;
      "paprika-recipe-manager-3" = 1303222628;
    };
  };
}
