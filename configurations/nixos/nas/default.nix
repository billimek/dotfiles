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

  # System architecture for this host
  nixpkgs.hostPlatform = "x86_64-linux";

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
    # Parent dataset: all regular directories with conservative snapshots
    "tank/backups" = {
      use_template = [ "backups" ]; # 0 hourly, 0 daily, 6 monthly, 2 yearly
      recursive = false; # Don't auto-snapshot child datasets
    };

    # Child dataset: Time Machine backups with more frequent snapshots
    "tank/backups/timemachine" = {
      use_template = [ "timemachine" ]; # 0 hourly, 14 daily, 6 monthly, 0 yearly
    };

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

  # Do NOT change this value. stateVersion determines compatibility for stateful data,
  # not which NixOS version you're running. Only change after reading release notes.
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
