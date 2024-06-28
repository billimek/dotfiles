# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    # nota-bene: this doesn't actually build, it fails with "/build/source/go.mod:3: invalid go version '1.21.0': must match format 1.23""
    acorn-next = prev.acorn.overrideAttrs (oldAttrs: {
      version = "v0.9.2";
      src = prev.fetchFromGitHub {
        owner = "acorn-io";
        repo = "acorn";
        rev = "v0.9.2";
        # obtained from `nix-shell -p nix-prefetch-github --run "nix-prefetch-github acorn-io acorn --rev v0.9.2"`
        hash = "sha256-l9V6URc5wY30z6W76n3xrGMHC43kDWfx0+1eznmcVi4=";
      };
      buildInputs = oldAttrs.buildInputs or [ ] ++ [ final.unstable.go ];
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
