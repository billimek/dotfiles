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
    # Do NOT change this value. stateVersion determines compatibility for stateful data,
    # not which home-manager version you're running. Only change after reading release notes.
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = lib.mkDefault "23.11";
  };

  # Common git configuration for nix user
  programs.git = {
    settings.user = {
      name = lib.mkDefault "billimek";
      email = lib.mkDefault "jeff@billimek.com";
      signingKey = lib.mkDefault "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhZTlonLeCLJpBtuSQcqofKoUbr2ajG3JXxZ7Gjdgkh";
    };
  };
}
