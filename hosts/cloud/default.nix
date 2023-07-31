{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../common/nixos
    ../common/nixos/auto-upgrade.nix
    ../common/nixos/users/jeff
    ../common/optional/docker.nix
    ../common/optional/fish.nix
    ../common/optional/qemu.nix
  ];

  networking = {
    hostName = "cloud";
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  };

  # may fix issues with network service failing during a nixos-rebuild
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";

}
