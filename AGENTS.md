# Repository instructions for coding agents

Nix flake managing NixOS hosts, nix-darwin (macOS) hosts, and Home Manager user configurations.

> **Edit target**: `CLAUDE.md` is a symlink → `AGENTS.md`. Always edit `AGENTS.md`.

## Architecture
- **Flake entry**: `flake.nix` uses **flake-parts**; outputs defined in `flake-module.nix`.
- **Auto-discovery**: `lib/autowire.nix` discovers configurations, modules, and packages — no manual wiring *except* where noted below.
- **Formatter**: `nixfmt-rfc-style` (run `nix fmt`).
- **Key inputs**: `nixpkgs` (25.11), `nixpkgs-unstable`, `home-manager`, `nix-darwin`, `flake-parts`, `determinate`, `opnix`, `nvf`.

## Directory layout
| Path | Purpose |
|---|---|
| `configurations/nixos/<host>/` | NixOS host configs (`home`, `nas`, `cloud`) |
| `configurations/darwin/<host>.nix` | nix-darwin host configs (`Jeffs-M3Pro`, `work-laptop`) |
| `users/<user>/` | Home Manager user configs; `hosts/<host>.nix` per-host overrides |
| `modules/nixos/` | Reusable NixOS modules (exported as `nixosModules`) |
| `modules/darwin/` | Reusable nix-darwin modules (exported as `darwinModules`) |
| `modules/home/` | Reusable Home Manager modules (exported as `homeManagerModules`) |
| `overlays/` | Nix overlays (aggregated in `overlays/default.nix`) |
| `packages/` | Custom packages (auto-discovered, exported as `packages`) |
| `lib/` | Helper library (`autowire.nix`) |

## Module pattern
Every module in this repo must follow this shape exactly:

```nix
{ config, lib, pkgs, ... }:
let cfg = config.modules.<name>;
in {
  imports = [ ... ];  # MUST be top-level — never inside mkIf
  options.modules.<name>.enable = lib.mkEnableOption "<description>";
  config = lib.mkIf cfg.enable { ... };
}
```

All discovered modules are **imported into every host of their class** automatically (via `imports = builtins.attrValues nixosModules`). To activate a module on a host, set `modules.<name>.enable = true;`.

To **default a module on** (always active unless explicitly disabled), merge `// { default = true; }` onto the `mkEnableOption` call.

## Default-on modules (no need to enable explicitly)
- **NixOS**: `base`, `locale`, `nix-settings`, `openssh`, `tailscale`, `nfs-client`, `systemd-initrd`, `x11`
- **Darwin**: `base`, `homebrew`, `determinate`
- **Home**: almost all modules — the only opt-in ones are `dev`, `kubernetes`, `zmx`

## Autowire exceptions (manual edits required)
1. **Overlays**: add entries to `overlays/default.nix` — the `discoverOverlays` function in `lib/autowire.nix` exists but is not used.
2. **NixOS users**: drop `modules/nixos/users/<user>.nix` *and* add it to the imports list in `modules/nixos/users/default.nix`.
3. **ARM Linux hosts**: hostname→system mapping is hardcoded in `lib/autowire.nix:38-50` (only `cloud` → `aarch64-linux`; everything else → `x86_64-linux`). New ARM hosts require editing `autowire.nix`.

## Enabling a user on a NixOS host
Use `modules.users.<user>.enable = true;` (not direct Home Manager wiring). The `users` module is a nested aggregator at `modules/nixos/users/`.

## `pkgs-unstable` availability
`pkgs-unstable` is injected via `specialArgs` for **Darwin and Home Manager only** (`lib/autowire.nix:163-167, 220-223`). In **NixOS modules**, use `pkgs.unstable.*` instead (the overlay added in `overlays/default.nix:10-15`).

## Darwin caveats
- **Determinate Nix owns `nix.conf`**: `modules/darwin/base.nix` sets `nix.enable = false`. Do not use `nix.settings.*` on Darwin — it has no effect.
- **Fish codesigning workaround on aarch64-darwin** is duplicated across `modules/darwin/base.nix:40-48` and `overlays/default.nix:20-24`. Removing one without the other will break fish on Apple Silicon.

## Secrets
- **`secrets.nix`** at repo root — encrypted via **git-crypt**. Imported at a relative path only by Darwin/work configs (`configurations/darwin/work-laptop.nix`, `users/jeff/hosts/work-laptop.nix`).
- **opnix** (1Password) — runtime secrets on NixOS hosts via `services.onepassword-secrets`. Configured in `modules/nixos/opnix.nix`.
- Never commit plaintext secrets.

## Conventions
- Follow the existing directory structure; autowiring picks up new files automatically (with the exceptions above).
- Keep edits minimal and consistent with nearby patterns.
- Commit messages use `scope: description` format. Common scopes: `flake`, `home`, `darwin`, `nixos`, `nas`, `cloud`, `docs`. Multi-scope example: `flake,home,darwin: ...`.

## Verify before committing
```
nix fmt          # format all .nix files
nix flake check  # catch eval errors
```
There is no CI build check — local verification is the only guardrail.

## Rebuild commands
- NixOS: `nh os switch .` or `sudo nixos-rebuild switch --flake .#<host>`
- macOS: `nh darwin switch .` or `darwin-rebuild switch --flake .#<host>`
- Home Manager: `nh home switch .` or `home-manager switch --flake .#<user@host>`
