{ inputs, ... }:
{
  imports = [ inputs.proxmox-nixos.nixosModules.proxmox-ve ];

  nixpkgs.overlays = [ inputs.proxmox-nixos.overlays.x86_64-linux ];

  services.proxmox-ve = {
    enable = true;
    ipAddress = "10.0.7.7";
  };

  virtualisation = {
    kvmgt.enable = true;
  };
}
