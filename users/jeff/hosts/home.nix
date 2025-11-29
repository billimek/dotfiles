# Home Manager configuration for jeff on home (VM)
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
    # dev.enable = true;  # commented out in original
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
