{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../common/nixos
    ../common/nixos/auto-upgrade.nix
    ../common/nixos/users/jeff
    ../common/optional/docker.nix
    ../common/optional/fish.nix
    ../common/optional/nfs-media.nix
    ../common/optional/nfs-ssdtank.nix
    ../common/optional/qemu.nix
    ../common/optional/reboot-required.nix
    ../common/optional/vscode-server.nix
  ];

  networking = {
    hostName = "cloud";
    firewall.enable = false;
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
  };

  # need to disable this for aarch64 due to https://github.com/NixOS/nixpkgs/issues/258515
  environment.enableAllTerminfo = lib.mkForce false;

  # may fix issues with network service failing during a nixos-rebuild
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
