{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.nixvirt.nixosModules.default];

  # configure for using virt-manager
  virtualisation = {
    libvirt.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [pkgs.OVMFFull.fd];
      };
    };
    kvmgt.enable = true;

    # WARNING: defining this will wipe-out any existing libvirt connections (i.e. virt-manager VMs you manually created)
    libvirt.connections = {
      "qemu:///system" = {
        domains = [
          {
            definition = ./domains/home.xml;
            active = true;
          }
          {
            definition = ./domains/k3s-0.xml;
            active = true;
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

  hardware.ksm.enable = true; # enable kernel same-page merging

  programs.virt-manager.enable = true;
}
