# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    acorn-override = prev.acorn.overrideAttrs (oldAttrs: rec {
      version = "0.9.1";
      src = prev.fetchFromGitHub {
        owner = "acorn-io";
        repo = "acorn";
        rev = "v0.9.1";
        # obtained from `nix-prefetch-github acorn-io acorn --rev v0.9.1`
        hash = "sha256-FPnKmWKnEFVDXbDI+An3EKzleP43NEC9/dq4SJfWQrU=";
      };
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
