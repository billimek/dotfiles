# Base Home Manager module - core configurations enabled by default
{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}:
let
  inherit (inputs.nix-colors) colorSchemes;
  cfg = config.modules.base;
in
{
  # Imports must be at top level (not inside mkIf)
  imports = [
    inputs.nix-colors.homeManagerModules.default
    inputs.opnix.homeManagerModules.default
    inputs.nvf.homeManagerModules.default
    inputs.nix-index-database.homeModules.nix-index
  ];

  options.modules.base = {
    enable = lib.mkEnableOption "base home-manager configuration" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs = {
      overlays = builtins.attrValues outputs.overlays;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };

    nix = {
      package = lib.mkDefault pkgs.nix;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        warn-dirty = false;
      };
    };

    systemd.user.startServices = "sd-switch";

    programs = {
      home-manager.enable = true;
      git.enable = true;
    };

    colorscheme = lib.mkDefault colorSchemes.dracula;
    home.file.".colorscheme".text = config.colorscheme.slug;

    home.sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
    ];
  };
}
