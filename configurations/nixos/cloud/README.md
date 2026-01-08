# Bootstrapping NixOS on 'cloud' VM

![](https://i.imgur.com/2Yl5fC4.png)

'cloud' is an Oracle Cloud free-tier VM:

* CPU:
  * Ampere A1
  * 4 Cores
* Memory:
  * 24GB
* Disk:
  * 200GB

It is installed with the NixOS following [this guide](https://mtlynch.io/notes/nix-oracle-cloud/) to replace an Ubuntu VM OS

## First Run (Bootstrap)
Here is where I will normally try and setup all the hardware and import the profiles/modules I want from this repo. Since I use the minimal install, I will kick things off like so:

```shell
ssh -A root@<ip of host>
nix-shell -p git vim
cd /etc/nixos
# these should no longer be needed if we already have the proper configurations already defined in the repo
sudo mv configuration.nix hardware-configuration.nix /tmp/
sudo git clone https://github.com/billimek/dotfiles.git .
sudo chown -R jeff:users .
```

Make any edits where necessary or desired, then build the configuration and _set the jeff user password_.  Once all is 'clean', it should be possible to reboot and login as the jeff user as a complete system.

```shell
sudo nixos-rebuild switch --flake .#cloud
passwd jeff
reboot
```

After reboot, login as jeff and set up Home Manager:

```shell
cd /etc/nixos
home-manager switch --flake .#jeff@cloud
```

## Day-to-Day Rebuilds

After initial setup, use `nh` for simpler rebuilds:

```shell
cd /etc/nixos
git pull
nh os switch    # NixOS system configuration
nh home switch  # Home Manager user configuration
```

## Things that need secrets

### 1Password bootstrapping auth

```shell
eval $(op signin --account <redacted>.1password.com)
```

### atuin login

```shell
atuin login --username $(op item get "atuin" --fields label=username) --password $(op item get "atuin" --fields label=password --reveal) --key "$(op item get "atuin" --fields label=key --reveal)"
atuin import auto
atuin sync
```

### kubeconfig

```shell
sudo tailscale set --operator=jeff
tailscale configure kubeconfig tailscale-operator
```
