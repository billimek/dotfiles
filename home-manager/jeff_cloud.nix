{ inputs, lib, pkgs, config, ... }: {
  imports = [
    ./common/global
    ./common/features/dev
    ./common/features/kubernetes
    inputs.nix-ld-vscode.nixosModules.default
  ];

  home = {
    username = lib.mkDefault "jeff";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.11";
    packages = with pkgs; [ _1password nfs-utils calibre ];
  };

  programs.git = {
    userName = "billimek";
    userEmail = "jeff@billimek.com";
    extraConfig = {
      user = {
        signingKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhZTlonLeCLJpBtuSQcqofKoUbr2ajG3JXxZ7Gjdgkh";
      };
    };
  };
}
