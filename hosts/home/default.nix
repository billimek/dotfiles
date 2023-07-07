{
  imports = [
    ./hardware-configuration.nix

    ../common/nixos
    ../common/nixos/users/jeff
    ../common/optional/docker.nix
    ../common/optional/fish.nix
    ../common/optional/nfs.nix
    ../common/optional/qemu.nix
  ];

  networking = {
    hostName = "home";
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  };
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";

}
