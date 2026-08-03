---
name: add-nix-component
description: How to add a new feature module, host, overlay, package, or NixOS user to this flake. Use when creating any new file under modules/, hosts/, or packages/.
---

1. **New feature module**: drop `modules/{nixos,darwin,home}-modules/<name>.nix` wrapped in `{ ... }: { flake.<class>Modules.<name> = <NixOS module>; }`. `import-tree` picks it up; nothing else to wire.
2. **New host**: add the host file(s) under `hosts/{nixos,darwin,home/<user>}/` and add a small `mkNixos`/`mkDarwin`/`mkHome` entry to `modules/wiring/hosts.nix` (system + `hostPath`, plus `sharedPath` for HM). System architecture is declared per host (no more `hostToSystem` heuristic — be explicit).
3. **New overlay**: drop `modules/overlays/<name>.nix` exporting `flake.overlays.<name> = final: prev: { ... }`.
4. **New package**: place the callPackage derivation at `packages/<name>.nix` and register it via `modules/packages/<name>.nix`:
   ```nix
   { ... }:
   {
     perSystem = { pkgs, ... }: {
       packages.<name> = pkgs.callPackage ../../packages/<name>.nix { };
     };
   }
   ```
5. **NixOS users**: `modules/nixos-modules/users-<user>.nix` is one self-contained module per user. Enable on a host via `modules.users.<user>.enable = true;`.
