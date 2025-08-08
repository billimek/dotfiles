# Repository instructions for GitHub Copilot and coding agents

This repository contains a Nix flake that manages NixOS hosts, nix-darwin (macOS) hosts, and Home Manager configurations.

## Project context
- Flake entry: `flake.nix` (exports NixOS, nix-darwin, and Home Manager configurations; provides `overlays`, `pkgs`, and formatters).
- Host configs live under `hosts/` (e.g., `hosts/home`, `hosts/nas`, `hosts/work_laptop`, `hosts/jeffs_laptop`).
- Shared host modules are under `hosts/common/*` (e.g., `hosts/common/nixos`, `hosts/common/darwin`).
- Home Manager configs live under `home-manager/` with reusable features in `home-manager/common/features/*` and examples in `home-manager/examples`.
- Reusable modules are exported via `modules/nixos` and `modules/home-manager`.
- Custom overlays live in `overlays/`; custom packages in `pkgs/` (aggregated by `pkgs/default.nix`).

## Conventions for changes
- Follow the existing directory structure and design when adding or modifying functionality.
  - Host-specific logic goes in the corresponding folder under `hosts/<host>/` and imports shared modules from `hosts/common/*`.
  - Reusable Home Manager bits belong under `home-manager/common/features/<area>/` and should be re-exported through the `default.nix` in that tree when appropriate.
  - New reusable NixOS or HM modules should be added under `modules/nixos` or `modules/home-manager` and exposed by the respective `default.nix`.
  - New overlays go in `overlays/` and should be wired via `overlays/default.nix`.
  - New custom packages go in `pkgs/` and should be referenced by `pkgs/default.nix`.
- Prefer minimal, localized edits; avoid large-scale refactors unless requested.
- Keep options/naming/style consistent with nearby files; mirror patterns already used in this repo.
- Do not commit secrets; use the existing secrets pattern (`secrets.nix`, `secrets-fallback.nix`).

## Shell command requirements (important)
- The local terminal is fish shell on macOS. All commands you ask the user to run in a terminal MUST be fish-compatible.
- Guidelines for fish-compatible commands:
  - Use command substitution with `(…)` instead of `$(…)`.
  - Use `and` / `or` instead of `&&` / `||`.
  - Use `;` to sequence commands when appropriate.
  - Export environment variables with `set -gx NAME VALUE` (not `export NAME=VALUE`). Local vars: `set -l`.
  - Arrays/lists are space-separated: `set -l PATHS a b c`.
  - Avoid bash-only idioms like `[[ … ]]`, process substitution `<(…)`, or `source <(curl …)`.
  - If you provide a script file, it can be POSIX sh/bash; only interactive commands shown for the terminal must be fish-compatible.

## Common Nix flows
- Format Nix: `nix fmt`
- Update inputs: `nix flake update`
- Evaluate/check (if checks are defined): `nix flake check`
- Rebuild/switch:
  - NixOS host: `sudo nixos-rebuild switch --flake .#<hostname>`
  - macOS (nix-darwin): `darwin-rebuild switch --flake .#<hostname>`
  - Home Manager (standalone): `home-manager switch --flake .#<user@hostname>`

## PR/commit guidance
- Keep PRs narrowly scoped and reference which host(s)/module(s) are affected.
- Include a brief note on how to apply or test (commands must be fish-compatible).

## Quick checklist for agents
- [ ] Confirm the change location matches the existing structure (hosts/common, modules, overlays, pkgs, HM features).
- [ ] Generate only fish-compatible terminal commands in instructions and examples.
- [ ] Keep edits minimal and consistent with nearby patterns.
- [ ] Avoid committing secrets; use the established secrets mechanism.
