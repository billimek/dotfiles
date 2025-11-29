# Proxmox VE hypervisor
{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.modules.proxmox;
in
{
  # Imports must be at top level (not inside mkIf)
  imports = [ inputs.proxmox-nixos.nixosModules.proxmox-ve ];

  options.modules.proxmox = {
    enable = lib.mkEnableOption "proxmox VE";
    ipAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.0.7.7";
      description = "IP address for Proxmox";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.proxmox-nixos.overlays.x86_64-linux ];

    services.proxmox-ve = {
      enable = true;
      ipAddress = cfg.ipAddress;
    };

    virtualisation = {
      kvmgt.enable = true;
    };
  };
}
