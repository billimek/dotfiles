---
name: audit-temp-patches
description: Find temporary upstream workarounds (marked TEMP-PATCH) and test which ones can be removed because nixpkgs or an input fixed the problem. Use when asked to audit, clean up, or remove workarounds/overlays, or when a CI build fails in a package that has a patch.
---

1. **List**: `rg -n TEMP-PATCH .` lists every workaround. Each marker names the upstream issue or the failure it covers.
2. **Check upstream state** for markers that cite an issue: `gh issue view <n> --repo NixOS/nixpkgs --json state,title`. Closed does not prove the fix reached the locked nixpkgs, so still do step 3.
3. **Test with the patch off**:
   - `doCheck = false` overlay: build the unpatched package from the locked input, e.g. `nix build --no-link --impure --expr 'let f = builtins.getFlake (toString ./.); in f.inputs.nixpkgs.legacyPackages.<system>.<pkg>'`. A package fetched from cache.nixos.org already passed its tests on Hydra. A local build that fails means the patch is still needed.
   - Overlay that forces a rebuild or override: remove it, then evaluate or build the affected host (`nix eval .#<attr>.drvPath`, or `nix build`).
   - Foreign-arch host (e.g. aarch64-linux cloud from darwin): cannot build locally; remove the patch and let the CI `Build updated configs` step decide.
   - Flake input pin or branch: `gh api repos/<owner>/<repo>/compare/<base>...<branch>` shows whether the branch is merged or still ahead.
4. **Remove** patches that pass: delete the overlay file or the lines, keep the `git add` rule from CLAUDE.md for new files, run `nix fmt`, then `nix flake check`.
5. **Report** per patch: still needed (with the failing evidence), removable (removed), or untestable locally (left for CI).
6. When adding a new workaround, put a one-line `# TEMP-PATCH: <upstream link or failure>` comment on it.

Test suite and build time: fastmcp and mcp-nixos checks take about 6 minutes. The macOS CI leg can take 50 minutes.
