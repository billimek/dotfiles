# Flake-parts module for autowiring configurations
{
  self,
  inputs,
  lib,
  ...
}:

let
  # Import autowiring helpers
  autowire = import ./lib/autowire.nix { inherit lib; };

  # Root directory of the flake
  root = ./.;

in
{
  # Per-system outputs (packages, formatter)
  perSystem =
    { pkgs, system, ... }:
    {
      # Custom packages accessible via 'nix build', 'nix shell', etc
      packages = autowire.discoverPackages {
        dir = root + /packages;
        inherit pkgs;
      };

      # Formatter for nix files, available via 'nix fmt'
      formatter = pkgs.nixfmt-rfc-style;
    };

  # Flake-wide outputs
  flake = {
    # Custom overlays - use the existing aggregator pattern
    overlays = import ./overlays { inherit inputs; };

    # Discover and export modules
    nixosModules = autowire.discoverModules { dir = root + /modules/nixos; };
    darwinModules = autowire.discoverModules { dir = root + /modules/darwin; };
    homeManagerModules = autowire.discoverModules { dir = root + /modules/home; };

    # Discover NixOS configurations
    nixosConfigurations = autowire.discoverNixosConfigurations {
      dir = root + /configurations/nixos;
      inherit inputs;
      outputs = self;
      nixosModules = self.nixosModules;
    };

    # Discover Darwin configurations
    darwinConfigurations = autowire.discoverDarwinConfigurations {
      dir = root + /configurations/darwin;
      inherit inputs;
      outputs = self;
      darwinModules = self.darwinModules;
    };

    # Discover Home Manager configurations
    homeConfigurations = autowire.discoverHomeConfigurations {
      dir = root + /users;
      inherit inputs;
      outputs = self;
      homeModules = self.homeManagerModules;
    };
  };
}
