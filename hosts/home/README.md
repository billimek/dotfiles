# Bootstrapping NixOS on 'home' VM

'home' is a qemu VM with the following configuration:

* CPU:
  * 1 CPU
  * 2 Cores
* Memory:
  * 4GB
* Disk:
  * 100GB
  * VirtIO
* NIC:
  * VirtIO

It is installed with the NixOS iso installation media.  These are the steps initially taken to install NixOS, though once the config is setup it can just be re-used for future re-installs if needed. This assumes you have booted into a NixOS install image from a USB stick and that we will be using systemd-boot.  Following the [manual installation steps](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual):

```shell
sudo -i
```

## Disk Setup

Creates 3 partitions on the virtual drive, one for EFI Boot, one for swap, and one for the primary partition.

```shell
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MB 512MB
parted /dev/sda -- mkpart primary linux-swap -8GB 100%
parted /dev/sda -- mkpart primary 512MB -8GB
parted /dev/sda -- set 1 esp on
mkfs.ext4 -L nixos /dev/sda3
mkswap -L swap /dev/sda2
mkfs.fat -F 32 -n boot /dev/sda1
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/sda2
```

## NixOS Install

Generate a config based on the currently detected hardware and disks.

```shell
nixos-generate-config --root /mnt
```

Next open the hardware and configuration nix files (`/mnt/etc/nixos/configuration.nix` & `/mnt/etc/nixos/hardware-configuration.nix`) to clean out comments and set basic information like hostname. Most of the other items are set by this configuration.

Now, lets install:

```shell
cd /mnt
sudo nixos-install
> <root password when prompted>
sudo reboot
```

## First Run

Here is where I will normally try and setup all the hardware and import the profiles/modules I want from this repo. Since I use the minimal install, I will kick things off like so:

```shell
nix-shell -p git vim
cd /etc/nixos
# these should no longer be needed if we already have the proper configurations already defined in the repo
mv configuration.nix hardware-configuration.nix /tmp/
git clone https://github.com/billimek/dotfiles.git .
nixos-rebuild switch
chown -R jeff:users .
reboot
```

Now it should be possible to login as the defined non-root user (i.e. `jeff`).  Be mindful that there is no password set for this user and only ssh-style key logins work. _May want to revisit this decision for situations where an ssh key is not available._

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
atuin sync -f
```

### kubeconfig

```shell
mkdir -p ~/.kube
op document get --vault kubernetes 'k3s.yaml' --out-file ~/.kube/config
```
