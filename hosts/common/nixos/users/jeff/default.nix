{
  pkgs,
  config,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.mutableUsers = true;
  users.users.jeff = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups =
      [
        "wheel"
      ]
      ++ ifTheyExist [
        "network"
        "docker"
        "git"
      ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmSHyH/Zxn9G+HPwWPkPfjlrqCYulCfO2JyS3pXUrYu"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhZTlonLeCLJpBtuSQcqofKoUbr2ajG3JXxZ7Gjdgkh"
    ];
    packages = [pkgs.home-manager];
  };

  home-manager.users.jeff = import ../../../../../home-manager/jeff_${config.networking.hostName}.nix;
}
