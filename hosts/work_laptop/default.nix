{
  config,
  pkgs,
  lib,
  home-manager,
  inputs,
  ...
}:
let
  secrets = import ../../secrets.nix;
in
{
  imports = [
    ../common/darwin/defaults.nix
    ./homebrew.nix
    ../common/optional/fish.nix
  ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/src.github/dotfiles/hosts/work_laptop/default.nix";

  # Create a system-wide alias for git so that keychain certs are properly used for https operations
  environment.shellAliases = {
    git = "/usr/bin/git";
  };

  security.pki.certificateFiles = [ secrets.work_certpath ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
