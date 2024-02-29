{
  pkgs,
  config,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  # this needs to be true in order to allow manual password setting via 'passwd' command
  users.mutableUsers = true;
  users.users.nix = {
    isNormalUser = true;
    shell = pkgs.fish;
    # this needs to be set to a proper password using 'passwd' after initial build
    initialPassword = "nix";
    extraGroups =
      [
        "wheel"
      ]
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
    packages = [pkgs.home-manager];
  };

  home-manager.users.nix = import ../../../../../home-manager/nix_${config.networking.hostName}.nix;
}
