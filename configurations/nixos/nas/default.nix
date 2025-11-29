# NixOS configuration for nas
{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  # Enable modules
  modules = {
    # Base modules (auto-enabled by default)
    # base.enable = true;
    # locale.enable = true;
    # nix-settings.enable = true;
    # openssh.enable = true;
    # tailscale.enable = true;
    # nfs-client.enable = true;
    # systemd-initrd.enable = true;
    # x11.enable = true;

    # Feature modules
    auto-upgrade.enable = true;
    avahi.enable = true;
    fish.enable = true;
    garage.enable = true;
    monitoring.enable = true;
    nfs-server.enable = true;
    opnix.enable = true;
    proxmox.enable = true;
    reboot-required.enable = true;
    rclone.enable = true;
    samba.enable = true;
    sanoid.enable = true;
    vscode-server.enable = true;
    zfs.enable = true;

    # User
    users.nix.enable = true;
  };

  users.groups = {
    nas.gid = 1001;
  };
  users.users = {
    nas = {
      group = "nas";
      uid = 1001;
      isSystemUser = true;
    };
  };

  boot.zfs.extraPools = [
    "tank"
    "ssdtank"
  ];

  services.smartd.enable = true;

  services.sanoid.datasets = {
    "tank/backups/timemachine".use_template = [ "timemachine" ];
    "ssdtank/proxmox" = {
      use_template = [ "vms" ];
      recursive = true;
    };
  };

  environment.systemPackages = with pkgs; [
    ipmitool
    lshw
    lsof
    pciutils
    rclone
    smartmontools
  ];

  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  system.stateVersion = "23.11";
}
