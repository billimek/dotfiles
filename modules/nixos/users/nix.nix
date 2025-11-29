# Nix user configuration for NixOS systems
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.users.nix;
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  options.modules.users.nix = {
    enable = lib.mkEnableOption "nix user";
  };

  config = lib.mkIf cfg.enable {
    users.mutableUsers = true;
    users.users.nix = {
      isNormalUser = true;
      shell = pkgs.fish;
      initialPassword = "nix";
      extraGroups =
        [ "wheel" ]
        ++ ifTheyExist [
          "network"
          "docker"
          "git"
          "libvirtd"
          "nas"
        ];

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmSHyH/Zxn9G+HPwWPkPfjlrqCYulCfO2JyS3pXUrYu"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhZTlonLeCLJpBtuSQcqofKoUbr2ajG3JXxZ7Gjdgkh"
      ];
      packages = [ pkgs.home-manager ];
    };
  };
}
