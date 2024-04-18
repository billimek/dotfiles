{ lib, pkgs, ... }: {
  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
  };
}
