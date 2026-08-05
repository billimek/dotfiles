{ ... }: {
  flake.nixosModules.base =
    # Base NixOS module - core configurations enabled by default
    {
      config,
      lib,
      pkgs,
      inputs,
      outputs,
      ...
    }:
    let
      cfg = config.modules.base;
    in
    {
      # Imports must be at top level (not inside mkIf)
      imports = [
        inputs.home-manager.nixosModules.home-manager
        inputs.opnix.nixosModules.default
      ];

      options.modules.base = {
        enable = lib.mkEnableOption "base NixOS configuration" // {
          default = true;
        };
      };

      config = lib.mkIf cfg.enable {
        home-manager.extraSpecialArgs = {
          inherit inputs outputs;
        };

        nixpkgs = {
          overlays = [
            outputs.overlays.additions
            outputs.overlays.unstable-packages
            outputs.overlays.opnix-overlay
          ];
          config = {
            allowUnfree = true;
          };
        };

        hardware.enableRedistributableFirmware = true;

        # Increase open file limit for sudoers
        security.pam.loginLimits = [
          {
            domain = "@wheel";
            item = "nofile";
            type = "soft";
            value = "524288";
          }
          {
            domain = "@wheel";
            item = "nofile";
            type = "hard";
            value = "1048576";
          }
        ];

        # Always install these for all users on nixos systems
        environment.systemPackages = [
          pkgs.opnix.default
          pkgs.git
          pkgs.htop
          pkgs.vim
          # nixos-26.05 pins nix-output-monitor 2.1.8; 2.2.0 adds per-download
          # progress bars. Override just nh's bundled nom -- nh wraps it with a
          # `--prefix PATH`, so a newer nom in systemPackages would be shadowed.
          (pkgs.nh.override { nix-output-monitor = pkgs.unstable.nix-output-monitor; })
        ];

        environment.variables = {
          NH_FLAKE = "/etc/nixos";
        };
      };
    };
}
