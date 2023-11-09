{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ./common/global
    #./common/features/dev
    ./common/features/cli/1password.nix
  ];

  home = {
    username = lib.mkDefault "root";
    homeDirectory = lib.mkDefault "/${config.home.username}";
    stateVersion = lib.mkDefault "23.05";
    sessionPath = ["$HOME/.local/bin"];
    packages = with pkgs; [
      _1password
    ];
  };

  programs.git = {
    userName = "billimek";
    userEmail = "jeff@billimek.com";
    extraConfig = {
      user = {
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhZTlonLeCLJpBtuSQcqofKoUbr2ajG3JXxZ7Gjdgkh";
      };
    };
  };

  programs.fish = {
    shellAbbrs = rec {
      # override with machine-specific values
      rehome = lib.mkForce "home-manager switch --flake $HOME/src/dotfiles/.#root@truenas";
    };
  };

  nixpkgs.overlays = [
    (final: prev: {
      fish = prev.fish.overrideAttrs (o: {
        patches =
          (o.patches or [])
          ++ [
            (pkgs.fetchpatch {
              name = "fix-zfs-completion.path";
              url = "https://github.com/fish-shell/fish-shell/commit/85504ca694ae099f023ae0febb363238d9c64e8d.patch";
              sha256 = "sha256-lA0M7E/Z0NjuvppC7GZA5rWdL7c+5l+3SF5yUe7nEz8=";
            })
          ];
      });
    })
  ];
}
