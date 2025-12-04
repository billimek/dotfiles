# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix flake-based dotfiles repository managing NixOS hosts, nix-darwin (macOS) hosts, and Home Manager configurations using a modular, auto-wiring architecture.

## Key Architecture

### Autowiring System

The repository uses a custom autowiring system (`lib/autowire.nix`) that auto-discovers configurations and modules based on directory structure. This eliminates boilerplate imports.

- **Configurations**: Automatically discovered from directory structure
  - NixOS: `configurations/nixos/<hostname>/default.nix` → `nixosConfigurations.<hostname>`
  - Darwin: `configurations/darwin/<hostname>.nix` → `darwinConfigurations.<hostname>`
  - Home Manager: `users/<user>/hosts/<host>.nix` → `homeConfigurations."<user>@<host>"`

- **Modules**: Auto-discovered and exported from module directories
  - Each `.nix` file in `modules/{nixos,darwin,home}/` becomes an importable module
  - All modules are automatically imported into their respective configurations
  - Modules use enable options for opt-in functionality

- **System Detection**: Architecture is determined automatically:
  - Darwin hosts: Always `aarch64-darwin` (detected by presence in `configurations/darwin/`)
  - NixOS hosts: Defaults to `x86_64-linux`, with explicit exceptions:
    - `cloud`: `aarch64-linux` (Oracle Cloud ARM)
    - Hosts set `nixpkgs.hostPlatform` explicitly in their configuration

### Module Pattern

Configurations declare which features to enable via `modules.<name>.enable = true;`:

```nix
# Example: configurations/nixos/nas/default.nix
modules = {
  # Base modules often auto-enabled
  auto-upgrade.enable = true;
  zfs.enable = true;
  samba.enable = true;
  # ... more modules
};
```

Available modules:
- **NixOS**: auto-upgrade, avahi, base, docker, fish, garage, locale, monitoring, nfs-client, nfs-mounts, nfs-server, nix-settings, openssh, opnix, oracle-cloud, proxmox, qemu, rclone, reboot-required, samba, sanoid, systemd-initrd, tailscale, users, vscode-server, x11, zfs
- **Darwin**: base, homebrew
- **Home Manager**: atuin, base, bash, bat, cli, copilot-cli, dev, direnv, fish, gh, ghostty, git, kubernetes, lsd, nvf, ssh, starship, tealdeer, tmux, zoxide

### User-Specific Configuration

Home Manager configs are organized by user first, then host:
- Shared user settings: `users/<user>/default.nix` (e.g., git config, common programs)
- Host-specific: `users/<user>/hosts/<host>.nix` (e.g., `users/jeff/hosts/Jeffs-M3Pro.nix`)

## Common Commands

All commands must be fish-shell compatible (not bash).

### Building and Switching

```fish
# NixOS hosts
sudo nixos-rebuild switch --flake .#<hostname>

# macOS (nix-darwin)
darwin-rebuild switch --flake .#<hostname>

# Home Manager standalone
home-manager switch --flake .#<user>@<hostname>
```

### Development

```fish
# Format all Nix files
nix fmt

# Update flake inputs
nix flake update

# Check flake (if checks defined)
nix flake check

# Build without activating
nix build .#darwinConfigurations.<hostname>.system
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

### Testing Modules

When adding or modifying modules, test by enabling them in a host config and rebuilding.

## Important Files

- `flake.nix`: Entry point with input declarations
- `flake-module.nix`: Flake-parts module that wires everything via autowiring
- `lib/autowire.nix`: Core autowiring logic for discovering configs/modules
- `secrets.nix`: Git-encrypted secrets file (git-crypt)

## Development Guidelines

### Fish Shell Compatibility

The local terminal uses fish shell on macOS. Always provide fish-compatible commands:
- Use `(command)` not `$(command)` for command substitution
- Use `and`/`or` instead of `&&`/`||`
- Use `set -gx VAR value` instead of `export VAR=value`
- Use `set -l VAR value` for local variables
- Avoid bash-isms like `[[`, `<()`, or `source <(curl ...)`

### Adding New Features

1. **New Module**: Create `modules/{nixos,darwin,home}/<name>.nix` with an enable option
   - The autowiring system will discover it automatically
   - No need to manually import in `default.nix`

2. **New Host**: Create appropriate config file:
   - NixOS: `configurations/nixos/<hostname>/default.nix` (with `hardware-configuration.nix`)
   - Darwin: `configurations/darwin/<hostname>.nix`
   - Set `nixpkgs.hostPlatform` for NixOS hosts if not x86_64-linux

3. **New User Home Config**: Create `users/<user>/hosts/<host>.nix`

4. **Custom Package**: Add to `packages/<name>.nix` (callPackage-compatible)

### Secrets

- Never commit plaintext secrets
- Use existing git-crypt pattern with `secrets.nix`
- Reference secrets as imports where needed

### State Version

Never change `system.stateVersion` or `home.stateVersion` unless explicitly migrating. These control compatibility for stateful data, not the NixOS/Home Manager version.

## Flake Inputs

Key dependencies managed in `flake.nix`:
- `nixpkgs`: NixOS 25.11 (stable)
- `nixpkgs-unstable`: Latest unstable packages
- `home-manager`: Release 25.11
- `nix-darwin`: Master branch (25.11 not released yet)
- Various tool-specific flakes (nvf, opnix, talhelper, etc.)

Lockfile updated daily via GitHub Actions.
