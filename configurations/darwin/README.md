# Darwin (macOS) Configurations

nix-darwin configurations for macOS hosts.

## Hosts

- [work-laptop](work-laptop.md) - Work MacBook Pro
- [Jeffs-M3Pro](Jeffs-M3Pro.md) - Jeff's personal MacBook Pro

## Prerequisites/Setup

* Install [nix](https://nixos.org/download.html)

```shell
sh <(curl -L https://nixos.org/nix/install) --daemon
```

* Install [nix-darwin](https://github.com/LnL7/nix-darwin)

```shell
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
 ```

It will probably be necessary to mess with some files in `/etc` like `/etc/bashrc` & `/etc/zshrc` to get a clean installation

* Install [homebrew](https://brew.sh/)

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Homebrew is used to install GUI packages that we don't want to install via nix.

## Bootstrap (First Run)

Clone the repository:

```shell
mkdir -p ~/src
cd ~/src
git clone https://github.com/billimek/dotfiles.git
cd dotfiles
```

Install the flake (substitute hostname as appropriate):

```shell
# First time nix-darwin setup (if not already installed)
nix run nix-darwin -- switch --flake .#work-laptop

# Or if nix-darwin is already installed
darwin-rebuild switch --flake .#work-laptop

# Set up Home Manager
home-manager switch --flake .#jeff@work-laptop
```

## Day-to-Day Rebuilds

After initial setup, use `nh` for simpler rebuilds:

```shell
cd ~/src/dotfiles
git pull
nh darwin switch  # Darwin system configuration
nh home switch    # Home Manager user configuration
```
