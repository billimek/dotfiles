{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}:
{
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

  system.primaryUser = "jeff";

  users.users.jeff = {
    description = "Jeff Billimek";
    # The shell setting currently does not work, see https://github.com/LnL7/nix-darwin/issues/811
    shell = pkgs.fish;
    home = "/Users/jeff";
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
