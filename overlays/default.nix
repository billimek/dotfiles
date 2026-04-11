# This file defines overlays
{ inputs, ... }:
{
  # Custom packages from the 'packages' directory
  additions = final: _prev: {
    kubectl-browse-pvc = final.callPackage ../packages/kubectl-browse-pvc.nix { };
  };

  # Unstable nixpkgs accessible via 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  # Workaround for aarch64-darwin codesigning bug (nixpkgs#208951 / #507531):
  # fish binaries from the binary cache can have invalid ad-hoc signatures on
  # Apple Silicon. Force a local rebuild so codesigning happens on this machine.
  fish-codesign-fix = _final: prev: {
    fish = prev.fish.overrideAttrs (_old: {
      NIX_FORCE_LOCAL_REBUILD = "darwin-codesign-fix";
    });
  };

  # External input overlays
  talhelper-overlay = final: _prev: {
    inherit (inputs.talhelper.packages.${final.stdenv.hostPlatform.system}) talhelper;
  };

  opnix-overlay = final: _prev: {
    opnix = inputs.opnix.packages.${final.stdenv.hostPlatform.system};
  };
}
