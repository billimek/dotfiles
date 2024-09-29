{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../common/nixos
    # this breaks because of git-secrets
    #../common/nixos/auto-upgrade.nix
    ../common/nixos/users/nix
    ../common/optional/avahi.nix
    ../common/optional/fish.nix
    ../common/optional/minio.nix
    ../common/optional/monitoring.nix
    ../common/optional/nfs.nix
    ../common/optional/reboot-required.nix
    ../common/optional/rclone.nix
    ../common/optional/samba.nix
    ../common/optional/sanoid.nix
    ../common/optional/virtulization
    ../common/optional/vscode-server.nix
    ../common/optional/zfs.nix
  ];

  users.groups = {
    nas.gid = 1001;
  };
  users.users = {
    nas = {
      group = "nas";
      uid = 1001;
      isSystemUser = true;
      # isNormalUser = true;
    };
  };

  boot.zfs.extraPools = [
    "tank"
    "ssdtank"
  ];

  services.smartd.enable = true;

  services.sanoid.datasets = {
    "tank/backups/timemachine".use_template = [ "timemachine" ];
    "ssdtank/vms/home".use_template = [ "vms" ];
    "ssdtank/vms/k3s-0".use_template = [ "vms" ];
    #"tank/backups".use_template = [ "backups" ];
    #"tank/media/photos".use_template = [ "backups" ];
    #"ssdtank/s3".use_template = [ "backups" ];
  };

  environment.systemPackages = with pkgs; [
    ipmitool
    lshw
    lsof
    pciutils
    rclone
    smartmontools
  ];

  # may fix issues with network service failing during a nixos-rebuild
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
