# Work MacBook pro

![](https://imgur.com/40LA1EX.png)

## Prerequieites/Setup

* Install [nix](https://nixos.org/download.html)

```shell
sh <(curl -L https://nixos.org/nix/install) --daemon
```

* Install [nix-dawrin](https://github.com/LnL7/nix-darwin)

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

## Use this flake

```shell
mkdir -p ~/src
cd ~/src
git clone https://github.com/billimek/dotfiles.git
```

Install the flake

```shell
darwin-rebuild switch --flake $HOME/src.github/dotfiles/.#work-laptop
home-manager switch --flake $HOME/src.github/dotfiles/.#jeff@work-laptop
```

## Things that need secrets

### 1Password bootstrapping auth

```shell
eval $(op signin --account <redacted>.1password.com)
```

### atuin login

```shell
atuin login --username $(op item get "atuin - THD" --vault Work --fields label=username) --password $(op item get "atuin - THD" --vault Work --fields label=password) --key "$(op item get "atuin - THD" --vault Work --fields label=key)"
atuin import auto
atuin sync
```

### kubeconfig

```shell
mkdir -p ~/.kube
op document get --vault kubernetes 'k3s.yaml' --out-file ~/.kube/config
```
