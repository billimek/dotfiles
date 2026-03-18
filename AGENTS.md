# Repository instructions for coding agents

Nix flake managing NixOS hosts, nix-darwin (macOS) hosts, and Home Manager user configurations.

## Architecture
- **Flake entry**: `flake.nix` uses **flake-parts**; outputs defined in `flake-module.nix`.
- **Auto-discovery**: `lib/autowire.nix` automatically discovers all configurations, modules, and packages from the directory tree -- no manual wiring needed when adding new files.
- **Formatter**: `nixfmt-rfc-style` (run `nix fmt`).

## Directory layout
| Path | Purpose |
|---|---|
| `configurations/nixos/<host>/` | NixOS host configs (`home`, `nas`, `cloud`) |
| `configurations/darwin/<host>.nix` | nix-darwin host configs (`Jeffs-M3Pro`, `work-laptop`) |
| `users/<user>/` | Home Manager user configs; `hosts/<host>.nix` per-host overrides |
| `modules/nixos/` | Reusable NixOS modules (exported as `nixosModules`) |
| `modules/darwin/` | Reusable nix-darwin modules (exported as `darwinModules`) |
| `modules/home/` | Reusable Home Manager modules (exported as `homeManagerModules`) |
| `overlays/` | Nix overlays (wired via `overlays/default.nix`) |
| `packages/` | Custom packages (auto-discovered, exported as `packages`) |
| `lib/` | Helper library (`autowire.nix`) |

## Secrets
- **`secrets.nix`** at repo root -- encrypted via **git-crypt**. Used by Darwin/work configs via `import`.
- **opnix** (1Password) -- runtime secrets on NixOS hosts via `services.onepassword-secrets`. Configured in `modules/nixos/opnix.nix`.
- Never commit plaintext secrets.

## Conventions
- Follow the existing directory structure; autowiring picks up new files automatically.
- Keep edits minimal and consistent with nearby patterns.
- Commit messages use `scope: description` format (e.g. `darwin: add homebrew cask`, `home: configure starship`).

## Rebuild commands
- NixOS: `nh os switch .` or `sudo nixos-rebuild switch --flake .#<host>`
- macOS: `nh darwin switch .` or `darwin-rebuild switch --flake .#<host>`
- Home Manager: `nh home switch .` or `home-manager switch --flake .#<user@host>`
