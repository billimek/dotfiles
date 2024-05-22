{ config, pkgs, ... }: {
  #homebrew packages
  homebrew = {
    casks = [
      "microsoft-remote-desktop"
      "obs"
      "slack"
      "visual-studio-code"
      "webex"
      "zoom"
    ];
    masApps = {
    };
  };
}
