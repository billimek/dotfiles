#!/usr/bin/env bash
# Bumps every pinned derivation under packages/*.nix via nix-update.
#
# nix-update rebuilds a fixed-output derivation to learn the real hash, which
# only works for the runner's own system. That's fine for buildGoModule
# packages (src/vendorHash content is platform-independent), but the
# hand-rolled prebuilt-binary packages here (stdenvNoCC.mkDerivation +
# fetchurl, selecting a per-system hash out of a `plat` set keyed on
# `stdenvNoCC.hostPlatform.system`) fetch a different tarball per platform, so
# nix-update only refreshes the branch matching the runner it's invoked on.
# The other platforms are backfilled below by evaluating (never building)
# each system's resolved download URL and expected hash, then prefetching the
# URL directly -- a plain download+hash that needs no matching build system.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

systems=(x86_64-linux aarch64-linux x86_64-darwin aarch64-darwin)
native_system=$(nix eval --raw --impure --expr builtins.currentSystem)

for f in packages/*.nix; do
  pkg=$(basename "$f" .nix)
  echo "== $pkg =="
  nix-update --flake "$pkg"

  if grep -q "hostPlatform.system" "$f"; then
    for sys in "${systems[@]}"; do
      [ "$sys" = "$native_system" ] && continue

      if ! current_hash=$(nix eval --raw ".#packages.${sys}.${pkg}.src.outputHash" 2>/dev/null); then
        continue
      fi
      url=$(nix eval --raw ".#packages.${sys}.${pkg}.src.url")
      real_hash=$(nix store prefetch-file --json "$url" | jq -r .hash)

      if [ "$current_hash" != "$real_hash" ]; then
        echo "  backfilling $sys hash"
        sd -F -- "$current_hash" "$real_hash" "$f"
      fi
    done
  fi
done
