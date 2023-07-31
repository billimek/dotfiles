# Bootstrapping NixOS on 'cloud' VM

![](https://i.imgur.com/9RaCuKF.png)

'cloud' is an Oracle Cloud free-tier VM:

* CPU:
  * Ampere A1
  * 4 Cores
* Memory:
  * 24GB
* Disk:
  * 200GB 

It is installed with the NixOS following [this guide](https://blog.korfuri.fr/posts/2022/08/nixos-on-an-oracle-free-tier-ampere-machine/) to takeover an Ubuntu VM OS

## First Run
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

Make any edits where necessary or desired, then build the configuration and _set the nix user password_.  Once all is 'clean', it should be possible to reboot and login as the nix user as a complete system.

```shell
sudo sh -c "cd /etc/nixos && git pull && nixos-rebuild switch"
passwd jeff
reboot
```

I will then be able to update the nixos-configuration repo in github and just pull/rebuild as needed on the machine. 

```shell
sudo sh -c "cd /etc/nixos && git pull && nixos-rebuild switch"
```

## Things that need secrets

### 1Password bootstrapping auth

```shell
eval $(op signin --account <redacted>.1password.com)
```

### atuin login

```shell
atuin login --username $(op item get "atuin" --fields label=username) --password $(op item get "atuin" --fields label=password) --key "$(op item get "atuin" --fields label=key)"
atuin import auto
atuin sync
```

### kubeconfig

```shell
mkdir -p ~/.kube
op document get --vault kubernetes 'k3s.yaml' --out-file ~/.kube/config
```
