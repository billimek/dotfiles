{ inputs, ... }:
{
  flake.overlays.talhelper-overlay = final: _prev: {
    inherit (inputs.talhelper.packages.${final.stdenv.hostPlatform.system}) talhelper;
  };
}
