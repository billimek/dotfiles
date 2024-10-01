{ inputs, ... }:
{
  imports = [ inputs.proxmox-nixos.nixosModules.proxmox-ve ];

  nixpkgs.overlays = [ inputs.proxmox-nixos.overlays.x86_64-linux ];

  # disabling until https://github.com/SaumonNet/proxmox-nixos/issues/28
  services.proxmox-ve.enable = false;
}
