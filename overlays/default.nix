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
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # External input overlays
  talhelper-overlay = final: _prev: {
    inherit (inputs.talhelper.packages.${final.system}) talhelper;
  };

  opnix-overlay = final: _prev: {
    opnix = inputs.opnix.packages.${final.system};
  };
}
