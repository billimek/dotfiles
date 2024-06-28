{ lib, pkgs, ... }:
{
  services.tailscale = {
    enable = true;
    package = pkgs.unstable.tailscale;
    useRoutingFeatures = lib.mkDefault "client";
  };
  networking.firewall = {
    checkReversePath = "loose";
    allowedUDPPorts = [ 41641 ]; # Facilitate firewall punching
  };
}
