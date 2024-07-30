{ config, pkgs, ... }:
{
  #homebrew packages
  homebrew = {
    taps = [
      "chainguard-dev/tap"
    ];
    brews = [
      "chainguard-dev/tap/chainctl"
    ];
    casks = [
      "arc"
      "gather"
      "microsoft-remote-desktop"
      "obs"
      "obsidian" # note taking app
      "VIA"
    ];
    masApps = { };
  };
}
