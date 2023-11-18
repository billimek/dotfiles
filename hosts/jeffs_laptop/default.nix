{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: {
  imports = [
    ../common/darwin/defaults.nix
    ./homebrew.nix
    ../common/optional/fish.nix
  ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/src/dotfiles/hosts/jeff_laptop/default.nix";

  networking.hostName = "Jeffs-M3Pro";

  # TODO: already set during installation of OS?
  # time.timeZone = lib.mkDefault "America/New_York";

  users.users.jeff = {
    description = "Jeff Billimek";
    shell = pkgs.fish;
    home = "/Users/jeff";
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
