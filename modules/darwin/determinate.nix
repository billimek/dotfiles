# Determinate Nix integration for Darwin
{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.modules.determinate;
in
{
  imports = [
    inputs.determinate.darwinModules.default
  ];

  options.modules.determinate = {
    enable = lib.mkEnableOption "Determinate Nix integration for Darwin" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    determinateNix = {
      enable = true;
      customSettings = {
        extra-substituters = [
          "https://nix-community.cachix.org"
          "https://nixpkgs-unfree.cachix.org"
        ];
        extra-trusted-substituters = [
          "https://nix-community.cachix.org"
          "https://nixpkgs-unfree.cachix.org"
        ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
        ];
      };
    };
  };
}
