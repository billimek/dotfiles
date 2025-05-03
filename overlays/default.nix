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

    # Override default nodejs with nodejs_22
    # https://github.com/NixOS/nixpkgs/issues/402079
    nodejs = prev.nodejs_22;
    nodejs-slim = prev.nodejs-slim_22;
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # Add talhelper overlay
  talhelper-overlay = final: _prev: {
    inherit (inputs.talhelper.packages.${final.system}) talhelper;
  };
  
  # Add opnix overlay
  opnix-overlay = final: _prev: {
    opnix = inputs.opnix.packages.${final.system};
  };

}
