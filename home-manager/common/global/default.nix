{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: let
  inherit (inputs.nix-colors) colorSchemes;
in {
  imports =
    [
      inputs.nix-colors.homeManagerModules.default
      ../features/cli
    ]
    ++ (builtins.attrValues outputs.homeManagerModules);

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
      experimental-features = ["nix-command" "flakes" "repl-flake"];
      warn-dirty = false;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  colorscheme = lib.mkDefault colorSchemes.dracula;
  home.file.".colorscheme".text = config.colorscheme.slug;

  home.sessionPath = ["$HOME/.local/bin" "$HOME/.cargo/bin"];
}
