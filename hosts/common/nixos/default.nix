# This file (and the global directory) holds config used on all hosts
{
  inputs,
  outputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    # ./auto-upgrade.nix # doesn't work right now with git-crypt repos - will revisit
    ./locale.nix
    ./nix.nix
    ./nfs.nix
    ./openssh.nix
    ./systemd-initrd.nix
    ./tailscale.nix
    ./x11.nix
  ] ++ (builtins.attrValues outputs.nixosModules);

  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
  };

  nixpkgs = {
    # You can add overlays here
    # overlays = builtins.attrValues outputs.overlays;
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  #environment.enableAllTerminfo = true;
  hardware.enableRedistributableFirmware = true;

  # Increase open file limit for sudoers
  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
    {
      domain = "@wheel";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
  ];

  # Enable printing changes on nix build etc with nvd
  #system.activationScripts.report-changes = ''
  #  PATH=$PATH:${
  #    lib.makeBinPath [
  #      pkgs.nvd
  #      pkgs.nix
  #    ]
  #  }
  #  nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)
  #'';

  # always install these for all users on nixos systems
  environment.systemPackages = [
    # pkgs.opnix.default
    pkgs.git
    pkgs.htop
    pkgs.vim
    pkgs.unstable.nh
  ];
}
