{ pkgs, lib, ... }:
let
  # Prefer Node.js 22 if available (required by Copilot CLI), fall back otherwise
  node = if pkgs ? nodejs_22 then pkgs.nodejs_22 else (pkgs.nodejs_latest or pkgs.nodejs);

  copilot = pkgs.writeShellScriptBin "copilot" ''
    #!${pkgs.bash}/bin/bash
    # Run GitHub Copilot CLI via npx so we don't need a separate package.
    # Requires network on first run to download @github/copilot.
    exec ${node}/bin/npx --yes @github/copilot "$@"
  '';
in
{
  home.packages = [ node copilot ];

  # Optional: ensure ~/.npm and cache directories exist to avoid first-run warnings
  home.activation.ensureNpmDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.npm" "$HOME/.cache/npm" || true
  '';
}
