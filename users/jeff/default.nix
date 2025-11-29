# Shared configuration for jeff user
{
  config,
  lib,
  pkgs,
  ...
}:
{
  home = {
    username = lib.mkDefault "jeff";
    # Do NOT change this value. stateVersion determines compatibility for stateful data,
    # not which home-manager version you're running. Only change after reading release notes.
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = lib.mkDefault "23.11";
  };

  # Common git configuration for jeff
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
