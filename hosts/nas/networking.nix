{
  config,
  lib,
  pkgs,
  ...
}: {
  networking = {
    hostName = "nas";
    hostId = "07aca0a7"; # generated from 'head -c 8 /etc/machine-id'
    networkmanager.enable = false; # Not sure if needed given that we're using systemd-networkd - diusabling this doesn't seem to break anything
    useDHCP = lib.mkDefault true; # Disable global DHCP
    useNetworkd = true;
    usePredictableInterfaceNames = true;
    firewall.enable = false;
    firewall.allowPing = true;
  };

  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;
    netdevs = {
      "20-br0" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br0";
          MACAddress = "00:02:c9:56:ff:6a";
          Description = "br0 bridged interface for enp2s0";
        };
      };
      "30-vlk8s20" = {
        netdevConfig = {
          Name = "vlk8s20";
          Kind = "vlan";
          Description = "VLAN 20 (k8s nodes)";
        };
        vlanConfig = {
          Id = 20;
        };
      };
      "40-k8s20" = {
        netdevConfig = {
          Name = "brk8s20";
          Kind = "bridge";
          # MACAddress = "<TBD>";
        };
      };
    };

    networks = {
      "20-tailscale-ignore" = {
        matchConfig.Name = "tailscale*";
        linkConfig = {
          Unmanaged = "yes";
          RequiredForOnline = false;
        };
      };
      "30-enp2s0" = {
        matchConfig.Name = "enp2s0";
        networkConfig = {
          Bridge = "br0";
          DHCP = "no";
        };
        vlan = [
          "vlk8s20"
        ];
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-eno2" = {
        matchConfig.Name = "eno2";
        networkConfig = {
          DHCP = "no"; # disabling DHCP for this interface because I observed egress traversing this instead of the 10GB enp2s0 which is no bueno
        };
      };
      "40-vlk8s20" = {
        matchConfig = {Name = "vlk8s20";};
        networkConfig = {
          Bridge = "brk8s20";
        };
      };
      "50-br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          DHCP = "yes";
        };
        linkConfig = {
          # or "routable" with IP addresses configured
          RequiredForOnline = "carrier";
        };
      };
      "50-brk8s20" = {
        matchConfig.Name = "brk8s20";
        networkConfig = {
          DHCP = "no";
        };
      };
      "99-network-defaults-wired" = {
        matchConfig.Name = "en* | eth* | usb*";
        networkConfig = {
          Description = "Fallback Wired DHCP";
          DHCP = "yes";
          IPForward = "yes";
        };
      };
    };
  };
}
