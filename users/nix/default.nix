# Shared configuration for nix user
{
  config,
  lib,
  pkgs,
  ...
}:
{
  home = {
    username = lib.mkDefault "nix";
    stateVersion = lib.mkDefault "23.11";
  };

  # Common git configuration for nix user
  programs.git = {
    userName = lib.mkDefault "billimek";
    userEmail = lib.mkDefault "jeff@billimek.com";
    extraConfig = {
      user = {
        signingKey = lib.mkDefault "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhZTlonLeCLJpBtuSQcqofKoUbr2ajG3JXxZ7Gjdgkh";
      };
    };
  };
}
