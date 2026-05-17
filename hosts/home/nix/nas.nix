# Home Manager configuration for nix on nas
{
  config,
  lib,
  pkgs,
  ...
}:
{
  modules.zmx.enable = true;

  home = {
    homeDirectory = "/home/${config.home.username}";
    packages = with pkgs; [
      _1password-cli
      gcc
      kopia
    ];
  };
}
