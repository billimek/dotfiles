{ pkgs, config, ... }:
let ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.mutableUsers = false;
  users.users.nix = {
    isNormalUser = true;
    shell = pkgs.fish;
    # this gets reset on every rebuild - need to find a better way to set the password without going down the path of sops
    # initialPassword = "nix";
    extraGroups = [
      "wheel"
    ] ++ ifTheyExist [
      "network"
      "docker"
      "git"
    ];

    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmSHyH/Zxn9G+HPwWPkPfjlrqCYulCfO2JyS3pXUrYu"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhZTlonLeCLJpBtuSQcqofKoUbr2ajG3JXxZ7Gjdgkh"
      ];
    packages = [ pkgs.home-manager ];
  };

  home-manager.users.nix = import ../../../../../home-manager/nix_${config.networking.hostName}.nix;
}
