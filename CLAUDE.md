# Repository instructions for coding agents

Nix flake managing NixOS hosts, nix-darwin (macOS) hosts, and Home Manager user configurations.

> **Edit target**: `AGENTS.md` is a symlink → `CLAUDE.md`. Always edit `CLAUDE.md`.

## Architecture
- **Pattern**: dendritic flake-parts via [`mightyiam/import-tree`](https://github.com/mightyiam/import-tree). `flake.nix` is `mkFlake` + `(import-tree ./modules)` — every `.nix` file under `./modules/` is a flake-parts module loaded recursively, and outputs are produced by option-merging.
- **Formatter**: `nixfmt-rfc-style` (run `nix fmt`).
- **Key inputs**: `nixpkgs` (25.11), `nixpkgs-unstable`, `home-manager`, `nix-darwin`, `flake-parts`, `import-tree`, `determinate`, `opnix`, `nvf`.

## Directory layout
| Path | Purpose |
|---|---|
| `modules/wiring/hosts.nix` | Central host registry (`mkNixos` / `mkDarwin` / `mkHome` helpers + every host listed explicitly) |
| `modules/wiring/options.nix` | Declares freeform options for flake outputs not declared by flake-parts (`darwinModules`, `homeManagerModules`, `darwinConfigurations`, `homeConfigurations`) |
| `modules/wiring/formatter.nix` | `perSystem.formatter` |
| `modules/nixos-modules/<name>.nix` | Reusable NixOS feature modules (exported via `flake.nixosModules.<name>`) |
| `modules/darwin-modules/<name>.nix` | Reusable nix-darwin feature modules (exported via `flake.darwinModules.<name>`) |
| `modules/home-modules/<name>.nix` | Reusable Home Manager feature modules (exported via `flake.homeManagerModules.<name>`) |
| `modules/overlays/<name>.nix` | One flake-parts module per overlay (`flake.overlays.<name>`) |
| `modules/packages/<name>.nix` | Registers a `perSystem.packages.<name>` from `packages/<name>.nix` |
| `hosts/nixos/<host>/` | NixOS host configs (`home`, `nas`, `cloud`) — NOT loaded by import-tree |
| `hosts/darwin/<host>.nix` | nix-darwin host configs (`Jeffs-M3Pro`, `work-laptop`) |
| `hosts/home/<user>/{default,<host>}.nix` | Home Manager: shared + per-host |
| `packages/<name>.nix` | Raw callPackage-style derivations |

> **Why hosts live outside `modules/`**: `import-tree` would try to load every host file as a flake-parts module. Host files are NixOS / Darwin / HM modules, not flake-parts modules, so they'd fail with module-system errors (e.g. unknown `modulesPath`). Keep them under `./hosts/` and reference them from `modules/wiring/hosts.nix`.

## Module pattern
Feature modules retain the NixOS-style shape but are wrapped in a flake-parts module that registers them under `flake.<class>Modules.<name>`:

```nix
# modules/nixos-modules/<name>.nix
{ ... }:
{
  flake.nixosModules.<name> = { config, lib, pkgs, ... }:
    let cfg = config.modules.<name>;
    in {
      imports = [ ... ];  # MUST be top-level — never inside mkIf
      options.modules.<name>.enable = lib.mkEnableOption "<description>";
      config = lib.mkIf cfg.enable { ... };
    };
}
```

All registered modules are imported into every host of their class via `modules/wiring/hosts.nix` (which does `imports = builtins.attrValues self.<class>Modules`). To activate a module on a host, set `modules.<name>.enable = true;` in the host file.

To **default a module on** (always active unless explicitly disabled), merge `// { default = true; }` onto the `mkEnableOption` call.

## Default-on modules (no need to enable explicitly)
- **NixOS**: `base`, `locale`, `nix-settings`, `openssh`, `tailscale`, `nfs-client`, `systemd-initrd`, `x11`
- **Darwin**: `base`, `homebrew`, `determinate`
- **Home**: almost all modules — the only opt-in ones are `dev`, `kubernetes`, `zmx`

## Adding things

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

## `pkgs-unstable` availability
`pkgs-unstable` is injected via `specialArgs` for **Darwin and Home Manager only** (`modules/wiring/hosts.nix`). In **NixOS modules**, use `pkgs.unstable.*` instead (provided by the `unstable-packages` overlay at `modules/overlays/unstable-packages.nix`).

## Darwin caveats
- **Determinate Nix owns `nix.conf`**: `modules/darwin-modules/base.nix` sets `nix.enable = false`. Do not use `nix.settings.*` on Darwin — it has no effect.
- **Fish codesigning workaround on aarch64-darwin** is duplicated across `modules/darwin-modules/base.nix` and `modules/overlays/fish-codesign-fix.nix`. Removing one without the other will break fish on Apple Silicon.

## Secrets
- **`secrets.nix`** at repo root — encrypted via **git-crypt**. Imported at a relative path only by Darwin/work configs (`hosts/darwin/work-laptop.nix` → `../../secrets.nix`, `hosts/home/jeff/work-laptop.nix` → `../../../secrets.nix`). Flake evaluation of these configs requires git-crypt unlocked.
- **opnix** (1Password) — runtime secrets on NixOS hosts via `services.onepassword-secrets`. Configured in `modules/nixos-modules/opnix.nix`.
- Never commit plaintext secrets.

## Conventions
- Drop new module files into the appropriate `modules/.../*.nix` location; `import-tree` picks them up automatically.
- Keep edits minimal and consistent with nearby patterns.
- Commit messages use `scope: description` format. Common scopes: `flake`, `home`, `darwin`, `nixos`, `nas`, `cloud`, `docs`. Multi-scope example: `flake,home,darwin: ...`.

## Git staging for flake evaluation
Before running `nh`, `nix flake check`, or any flake build, `git add` any new files. Nix flakes only evaluate git-tracked files; untracked new modules will silently be missing from the evaluation.

## Verify before committing
```
nix fmt          # format all .nix files
nix flake check  # catch eval errors (needs git-crypt unlocked if work-laptop is in scope)
```
There is no CI build check — local verification is the only guardrail.

## Rebuild commands
- NixOS: `nh os switch .` or `sudo nixos-rebuild switch --flake .#<host>`
- macOS: `nh darwin switch .` or `darwin-rebuild switch --flake .#<host>`
- Home Manager: `nh home switch .` or `home-manager switch --flake .#<user@host>`
