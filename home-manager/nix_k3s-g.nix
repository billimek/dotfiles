{ inputs, lib, pkgs, config, ... }:
{
  imports = [
    ./common/global
  ];

  home = {
    username = lib.mkDefault "nix";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.05";
    sessionPath = [ "$HOME/.local/bin" ];
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

}
