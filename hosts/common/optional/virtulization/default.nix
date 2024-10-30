{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.nixvirt.nixosModules.default ];

  hardware.ksm.enable = true; # enable kernel same-page merging

  # configure for using virt-manager
  virtualisation = {
    kvmgt.enable = true;

    libvirt.enable = false;
    libvirtd = {
      enable = false;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };

    # WARNING: defining this will wipe-out any existing libvirt connections (i.e. virt-manager VMs you manually created)
    libvirt.connections = {
      "qemu:///system" = {
        domains = [
          {
            definition = ./domains/home.xml;
            active = false;
          }
          {
            definition = ./domains/k3s-0.xml;
            active = false;
          }
        ];
        pools = [
          {
            definition = ./pools/iso.xml;
            active = true;
          }
          {
            definition = ./pools/pool.xml;
            active = true;
          }
        ];
      };
    };
  };
  programs.virt-manager.enable = false;
}
