{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../common/nixos
    ../common/nixos/users/nix
    ../common/optional/fish.nix
    ../common/optional/k3s-agent.nix
  ];

  time.timeZone = lib.mkForce "UTC";

  networking = {
    hostName = "k3s-f";
    timeServers = [ "10.0.7.1" ];
    firewall.enable = false;
    networkmanager.enable = false;  # Easiest to use and most distros use this by default.
  };

  # may fix issues with network service failing during a nixos-rebuild
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";

}
