{ ... }:
{
  # TEMP-PATCH: nixpkgs#208951 nixpkgs#507531 (fish cache signatures invalid on aarch64-darwin); also in modules/darwin-modules/base.nix
  # Guarded to aarch64-darwin because every host applies all overlays.
  flake.overlays.fish-codesign-fix = _final: prev: {
    fish =
      if prev.stdenv.hostPlatform.isDarwin && prev.stdenv.hostPlatform.isAarch64 then
        prev.fish.overrideAttrs (_old: {
          NIX_FORCE_LOCAL_REBUILD = "darwin-codesign-fix";
        })
      else
        prev.fish;
  };
}
