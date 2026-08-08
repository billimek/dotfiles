# Repository instructions for coding agents

Nix flake managing NixOS hosts, nix-darwin (macOS) hosts, and Home Manager user configurations.

> **Edit target**: `AGENTS.md` is a symlink → `CLAUDE.md`. Always edit `CLAUDE.md`.

## Architecture
- **Pattern**: dendritic flake-parts via [`mightyiam/import-tree`](https://github.com/mightyiam/import-tree). `flake.nix` is `mkFlake` + `(import-tree ./modules)` — every `.nix` file under `./modules/` is a flake-parts module loaded recursively, and outputs are produced by option-merging.

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

## `pkgs-unstable` availability
`pkgs-unstable` is injected via `specialArgs` for **Darwin and Home Manager only** (`modules/wiring/hosts.nix`). In **NixOS modules**, use `pkgs.unstable.*` instead (provided by the `unstable-packages` overlay at `modules/overlays/unstable-packages.nix`).

## Darwin caveats
- **Determinate Nix owns `nix.conf`**: `modules/darwin-modules/base.nix` sets `nix.enable = false`. Do not use `nix.settings.*` on Darwin — it has no effect.
- **Fish codesigning workaround on aarch64-darwin** is duplicated across `modules/darwin-modules/base.nix` and `modules/overlays/fish-codesign-fix.nix`. Removing one without the other will break fish on Apple Silicon.

## Secrets
Four mechanisms, each scoped to a different point in the config lifecycle — reach for the one that matches, don't blend them:
- **`secrets.nix`** at repo root — encrypted via **git-crypt**, for **eval-time** values (Nix evaluation is pure and can't call out to a provider). Imported at a relative path only by Darwin/work configs (`hosts/darwin/work-laptop.nix` → `../../secrets.nix`, `hosts/home/jeff/work-laptop.nix` → `../../../secrets.nix`). Flake evaluation of these configs requires git-crypt unlocked.
- **opnix** (1Password) — **runtime** secrets on NixOS hosts, delivered as owned files (not env vars) via `services.onepassword-secrets`. Configured in `modules/nixos-modules/opnix.nix`; consumed by garage, rclone, nut, gatus.
- **secretspec** (`modules/home-modules/secretspec.nix`) — secrets a **stdio MCP server needs injected into its own process env at launch**, e.g. `modules.claude-code.extraMcpServers.grafana` on Jeffs-M3Pro. Resolves from 1Password via `secretspec run` at process start, using a cached provider alias that serves repeat reads from the login keychain for `modules.secretspec.cacheMaxAge` (default 12h) so `op` isn't hit — and a 1Password biometric prompt isn't raised — on every MCP server launch. Never written into `~/.claude.json`, unlike the old `$(op read ...)` pattern it replaces there.
- **`op read` at home-manager activation** — the older pattern, still used where secretspec's model doesn't fit: HTTP-transport MCP servers whose token rides in an `Authorization` header string, e.g. `leanix` on work-laptop (`hosts/home/jeff/work-laptop.nix`), since there's no child process for `secretspec run` to wrap. Resolved once per `nh home switch` and baked into `~/.claude.json`; a locked vault at switch time fails the switch rather than silently registering an empty token.
- Never commit plaintext secrets.

## Verifying option names with mcp-nixos
When adding or changing Nix options, verify the exact option path and accepted values using the
`mcp-nixos` tools (`nixos_search`, `nixos_info`, `home_manager_options_by_prefix`,
`darwin_options_by_prefix`, etc.) rather than guessing. There is no CI build check — eval errors
are caught only at local build time.

## Conventions
- Drop new module files into the appropriate `modules/.../*.nix` location; `import-tree` picks them up automatically.
- Keep edits minimal and consistent with nearby patterns.
- **`~/.claude/settings.json` is copied, never symlinked.** Claude Code's settings writer opens the
  file with `O_NOFOLLOW` and refuses to write through a symlink, so a store symlink there makes
  every runtime settings write fail silently — including its one-time org-default reconciliation,
  which then retried forever and reset `model = "opusplan"` to the org default on every startup.
  Both upstream reports (`anthropics/claude-code#15786`, `#55485`) were closed as not planned, so
  this is settled behavior. `modules/home-modules/claude-code.nix` therefore leaves
  `programs.claude-code.settings` empty (home-manager only creates the symlink when it is
  non-empty) and installs the generated JSON via `home.activation.claudeSettings` with
  `install -m 644`. Consequence: nix is the source of truth and the file is overwritten on every
  switch, so runtime `/config` and `/effort` changes do not survive a rebuild — put anything
  durable in `defaultSettings`. Before overwriting, activation stashes a timestamped copy in
  `~/.claude/settings-drift/` whenever the live file differs semantically from what nix installs;
  run `/reconcile-claude-settings` to triage those and fold the keepers into `defaultSettings`.
  Do not "fix" this by switching to `home.file`, including `mkOutOfStoreSymlink`: both still
  produce a symlink.
- Commit messages use `scope: description` format. Common scopes: `flake`, `home`, `darwin`, `nixos`, `nas`, `cloud`, `docs`. Multi-scope example: `flake,home,darwin: ...`.

## Git staging for flake evaluation
Before running `nh`, `nix flake check`, or any flake build, `git add` any new files. Nix flakes only evaluate git-tracked files; untracked new modules will silently be missing from the evaluation.

## Verify before committing
```
nix fmt          # format all .nix files
nix flake check  # catch eval errors (needs git-crypt unlocked if work-laptop is in scope)
```
There is no CI build check — local verification is the only guardrail.
