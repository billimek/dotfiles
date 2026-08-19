{ ... }:
{
  # statix's checkPhase (insta snapshot tests) fails on nixos-26.05 as of
  # 2026-05-14 -- an upstream packaging bug (snapshot/insta version mismatch),
  # not anything in this repo. statix is pulled in transitively by nvf
  # (modules/home-modules/nvf.nix, languages.nix.enable) for its :Statix
  # nvim plugin. Skip its test suite until nixpkgs fixes it upstream.
  flake.overlays.statix-no-check = final: prev: {
    statix = prev.statix.overrideAttrs (_: {
      doCheck = false;
    });
  };
}
