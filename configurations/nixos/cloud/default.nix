# NixOS configuration for cloud (Oracle Cloud VM)
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
    nfs-mounts.ssdtank.enable = true;
    qemu.enable = true;
    reboot-required.enable = true;
    vscode-server.enable = true;

    # User
    users.jeff.enable = true;
  };

  networking = {
    hostName = "cloud";
    firewall.enable = false;
    networkmanager.enable = true;
  };

  # need to disable this for aarch64 due to https://github.com/NixOS/nixpkgs/issues/258515
  environment.enableAllTerminfo = lib.mkForce false;

  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  system.stateVersion = "23.11";
}
