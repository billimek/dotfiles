# Nix daemon settings, garbage collection, and registry
{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.modules.nix-settings;
in
{
  options.modules.nix-settings = {
    enable = lib.mkEnableOption "nix settings" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    nix = {
      settings = {
        trusted-users = [
          "root"
          "@wheel"
        ];
        auto-optimise-store = lib.mkDefault true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        warn-dirty = false;
        system-features = [
          "kvm"
          "big-parallel"
          "nixos-test"
        ];

        substituters = [
          "https://nix-community.cachix.org"
          "https://nixpkgs-unfree.cachix.org"
          "https://cache.saumon.network/proxmox-nixos"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
          "proxmox-nixos:D9RYSWpQQC/msZUWphOY2I5RLH5Dd6yQcaHIuug7dWM="
        ];
      };

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 2d";
      };

      # Add each flake input as a registry
      registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

      # Add nixpkgs input to NIX_PATH
      nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];
    };
  };
}
