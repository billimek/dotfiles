# Darwin configuration for work laptop
{
  inputs,
  pkgs,
  ...
}:
let
  secrets = import ../../secrets.nix;
in
{
  # Enable modules (base and homebrew are auto-enabled)
  modules = {
    # All base darwin modules are auto-enabled
  };

  environment.darwinConfig = "$HOME/src.github/dotfiles/configurations/darwin/work-laptop.nix";

  # Create a system-wide alias for git so that keychain certs are properly used for https operations
  environment.shellAliases = {
    git = "/usr/bin/git";
  };

  security.pki.certificateFiles = [ "/usr/local/munki/thd_certs.pem" ];

  system.primaryUser = secrets.work_username;

  # Additional homebrew packages specific to this machine
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
      "obsidian"
      "VIA"
      "zed"
    ];
    masApps = { };
  };

  system.stateVersion = 5;
}
