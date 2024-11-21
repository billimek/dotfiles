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
      "obsidian" # note taking app
      "VIA"
    ];
    masApps = { };
  };
}
