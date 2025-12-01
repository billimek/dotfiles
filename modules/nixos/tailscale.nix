# Tailscale VPN configuration
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.tailscale;
in
{
  options.modules.tailscale = {
    enable = lib.mkEnableOption "tailscale VPN" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      package = pkgs.tailscale;
      useRoutingFeatures = lib.mkDefault "client";
    };
    networking.firewall = {
      checkReversePath = "loose";
      allowedUDPPorts = [ 41641 ]; # Facilitate firewall punching
    };
  };
}
