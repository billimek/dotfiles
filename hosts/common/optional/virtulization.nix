{
  config,
  pkgs,
  ...
}: {
  # configure for using virt-manager
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}
