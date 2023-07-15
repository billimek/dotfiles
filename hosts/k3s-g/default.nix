{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../common/nixos
    ../common/nixos/users/nix
    ../common/optional/fish.nix
    # ../common/optional/k3s-agent.nix
  ];

  time.timeZone = lib.mkForce "UTC";

  environment.systemPackages = [
    pkgs.nfs-utils
  ];

  networking = {
    hostName = "k3s-g";
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  };

  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;
    netdevs = {
      "20-vlan20" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan20";
        };
        vlanConfig.Id = 20;
      };
    };
    networks = {
      "30-enp4s0" = {
        matchConfig.Name = "enp4s0";
        # using dhcp for vlan20 instead
        networkConfig.DHCP = "no";
        #linkConfig.RequiredForOnline = "no";
        # tag vlan on this link
        vlan = [
          "vlan20"
        ];
      };
      "40-vlan20" = {
        matchConfig.Name = "vlan20";
        # acquire a DHCP lease on link up
        networkConfig.DHCP = "yes";
        # ensure that all k8s nodes use the router ntp server for clock consistency
        networkConfig.NTP = "10.0.7.1";
        networkConfig.IPv6AcceptRA = true;
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";

}
