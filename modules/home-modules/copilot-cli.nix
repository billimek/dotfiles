{ ... }: {
  flake.homeManagerModules.copilot-cli =
    # GitHub Copilot CLI
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.modules.copilot-cli;
      # Use the default nodejs from nixpkgs (currently Node 24).
      node = pkgs.nodejs;

      copilot = pkgs.writeShellScriptBin "copilot" ''
        #!${pkgs.bash}/bin/bash
        # Run GitHub Copilot CLI via npx so we don't need a separate package.
        # Requires network on first run to download @github/copilot.
        exec ${node}/bin/npx --yes @github/copilot "$@"
      '';
    in
    {
      options.modules.copilot-cli = {
        enable = lib.mkEnableOption "GitHub Copilot CLI" // {
          default = true;
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = [
          node
          copilot
        ];

        # Optional: ensure ~/.npm and cache directories exist to avoid first-run warnings
        home.activation.ensureNpmDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "$HOME/.npm" "$HOME/.cache/npm" || true
        '';
      };
    };
}
