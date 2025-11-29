# Work MacBook pro

![](https://imgur.com/40LA1EX.png)

## Prerequisites/Setup

See [README.md](README.md) for general Darwin setup instructions.

## Bootstrap (First Run)

```shell
cd ~/src/dotfiles
darwin-rebuild switch --flake .#work-laptop
home-manager switch --flake .#jeff@work-laptop
```

## Day-to-Day Rebuilds

```shell
cd ~/src/dotfiles
git pull
nh darwin switch  # Darwin system configuration
nh home switch    # Home Manager user configuration
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
