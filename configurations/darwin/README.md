# Darwin (macOS) Configurations

nix-darwin configurations for macOS hosts.

## Hosts

- `work-laptop` - Work MacBook Pro
- `Jeffs-M3Pro` - Jeff's personal MacBook Pro

## Prerequisites/Setup

### 1. Install Nix

Use the [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer).
It enables flakes by default, survives macOS upgrades, and supports clean uninstallation.

```shell
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

### 2. Install Homebrew

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Homebrew is used for GUI apps and packages not managed via Nix.

### 3. Clone the repository

| Host | Clone path |
|------|-----------|
| `work-laptop` | `~/src.github/dotfiles` |
| `Jeffs-M3Pro` | `~/src/dotfiles` |

```shell
# work-laptop
mkdir -p ~/src.github && git clone https://github.com/billimek/dotfiles.git ~/src.github/dotfiles

# Jeffs-M3Pro
mkdir -p ~/src && git clone https://github.com/billimek/dotfiles.git ~/src/dotfiles
```

## Bootstrap (First Run)

`darwin-rebuild` is not yet on `PATH` on a fresh machine, so use `nix run` for the first switch.

The flake configuration names (`work-laptop`, `Jeffs-M3Pro`) are fixed identifiers from
`configurations/darwin/` — they do **not** need to match the machine's actual hostname.

The `nix-darwin-25.11` ref must match the `nix-darwin` input pin in `flake.nix`. Update it
if the flake is ever bumped to a new nixpkgs release.

**work-laptop:**

```shell
cd ~/src.github/dotfiles
sudo nix run nix-darwin/nix-darwin-25.11#darwin-rebuild -- switch --flake .#work-laptop
home-manager switch --flake .#jeff@work-laptop
```

**Jeffs-M3Pro:**

```shell
cd ~/src/dotfiles
sudo nix run nix-darwin/nix-darwin-25.11#darwin-rebuild -- switch --flake .#Jeffs-M3Pro
home-manager switch --flake .#jeff@Jeffs-M3Pro
```

nix-darwin may warn about existing files in `/etc` (e.g. `/etc/bashrc`, `/etc/zshrc`).
Follow the prompts to back them up and allow nix-darwin to take over.

After the first switch, `darwin-rebuild` will be on `PATH` for future rebuilds.

## Day-to-Day Rebuilds

After initial setup, use `nh` for simpler rebuilds:

```shell
git pull
nh darwin switch  # Darwin system configuration
nh home switch    # Home Manager user configuration
```

## Post-Bootstrap Secrets

### 1Password auth

Sign in first to unlock the vault before fetching other secrets:

```shell
eval (op signin --account <redacted>.1password.com)
```

### git-crypt (work-laptop only)

`secrets.nix` is encrypted with git-crypt. Unlock it before running any `darwin-rebuild`
or `home-manager switch` — the flake will fail to evaluate without it:

```shell
op document get --vault Personal 'git-crypt-key' --out-file /tmp/git-crypt-key
git-crypt unlock /tmp/git-crypt-key
rm /tmp/git-crypt-key
```

### atuin login

```shell
atuin login --username (op item get "atuin - THD" --vault Work --fields label=username) --password (op item get "atuin - THD" --vault Work --fields label=password) --key (op item get "atuin - THD" --vault Work --fields label=key)
atuin import auto
atuin sync
```

