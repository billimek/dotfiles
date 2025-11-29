# This file defines overlays
{ inputs, ... }:
{
  # Custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

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
