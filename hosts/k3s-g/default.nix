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
    vlans = {
      # force enp4s0 to vlan20 (k8s nodes) but leave enp1s0 untouched
      vlan20 = { id=20; interface="enp4s0"; };
    };
    # ensure that all k8s nodes use the router ntp server for clock consistency
    timeServers = [ "10.0.7.1" ]; 
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  };

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
        # tag vlan on this link
        vlan = [
          vlan20
        ];
      };
      "40-vlan20" = {
        matchConfig.Name = "vlan20";
        # acquire a DHCP lease on link up
        networkConfig.DHCP = "ipv4";
        networkConfig.IPv6AcceptRA = true;
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";

}
