# Home Manager configuration for jeff on cloud (Oracle Cloud VM)
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../default.nix
  ];

  # Enable optional feature modules
  modules = {
    dev.enable = true;
    kubernetes.enable = true;
  };

  home = {
    homeDirectory = "/home/${config.home.username}";
    packages = with pkgs; [
      _1password-cli
      nfs-utils
      calibre
    ];
  };
}
