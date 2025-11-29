# NixOS configuration for home (VM in NAS)
{
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Enable modules
  modules = {
    # Feature modules
    auto-upgrade.enable = true;
    docker.enable = true;
    fish.enable = true;
    nfs-mounts.media.enable = true;
    qemu.enable = true;
    reboot-required.enable = true;
    vscode-server.enable = true;

    # User
    users.jeff.enable = true;
  };

  networking = {
    hostName = "home";
    networkmanager.enable = true;
    dhcpcd.enable = false;
  };

  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  system.stateVersion = "23.11";
}
