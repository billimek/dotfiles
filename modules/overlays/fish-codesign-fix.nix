{ ... }:
{
  # Workaround for aarch64-darwin codesigning bug (nixpkgs#208951 / #507531):
  # fish binaries from the binary cache can have invalid ad-hoc signatures on
  # Apple Silicon. Force a local rebuild so codesigning happens on this machine.
  # Guarded to aarch64-darwin only -- this overlay is applied unconditionally to
  # every host (home-modules/base.nix applies all `outputs.overlays`), so without
  # the guard Linux hosts would rebuild fish from source for a bug that can't
  # affect them.
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
