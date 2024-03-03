{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../common/nixos
    ../common/nixos/auto-upgrade.nix
    ../common/nixos/users/nix
    ../common/optional/avahi.nix
    ../common/optional/fish.nix
    ../common/optional/minio.nix
    ../common/optional/monitoring.nix
    ../common/optional/nfs.nix
    ../common/optional/reboot-required.nix
    ../common/optional/samba.nix
    ../common/optional/virtulization.nix
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

  boot.zfs.extraPools = ["tank" "ssdtank"];

  services.smartd.enable = true;

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
