{ config, pkgs, ... }: {
  #homebrew packages
  homebrew = {
    casks = [
      "arc"
      "gather"
      "microsoft-remote-desktop"
      "obs"
      "obsidian" # note taking app
      "plex"
      "VIA"
    ];
    masApps = {
    };
  };
}
