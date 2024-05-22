{ config, pkgs, ... }: {
  #homebrew packages
  homebrew = {
    casks = [
      "microsoft-remote-desktop"
      "slack"
      "webex"
      "zoom"
    ];
    masApps = {
    };
  };
}
