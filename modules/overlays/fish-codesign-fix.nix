{ ... }:
{
  # Workaround for aarch64-darwin codesigning bug (nixpkgs#208951 / #507531):
  # fish binaries from the binary cache can have invalid ad-hoc signatures on
  # Apple Silicon. Force a local rebuild so codesigning happens on this machine.
  flake.overlays.fish-codesign-fix = _final: prev: {
    fish = prev.fish.overrideAttrs (_old: {
      NIX_FORCE_LOCAL_REBUILD = "darwin-codesign-fix";
    });
  };
}
