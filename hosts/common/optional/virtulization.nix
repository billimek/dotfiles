{
  config,
  pkgs,
  ...
}: {
  # configure for using virt-manager
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    kvmgt.enable = true;
  };

  programs.virt-manager.enable = true;
}
