# NixOS configuration for home (VM in NAS)
{
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # System architecture for this host
  nixpkgs.hostPlatform = "x86_64-linux";

  # Enable modules
  modules = {
    # Feature modules
    auto-upgrade.enable = true;
    docker.enable = true;
    fish.enable = true;
    nfs-mounts.media.enable = true;
    nfs-mounts.backups.enable = true;
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

  # Do NOT change this value. stateVersion determines compatibility for stateful data,
  # not which NixOS version you're running. Only change after reading release notes.
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
