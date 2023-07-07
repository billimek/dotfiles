# Bootstrapping NixOS on 'home' VM

'home' is a TrueNAS qemu VM with the following configuration:

* CPU:
  * 1 CPU
  * 2 Cores
  * 4 Threads
* Memory:
  * 4GB
* Disk:
  * 150GB 
  * VirtIO
* NIC:
  * VirtIO

It is installed with the NixOS iso installation media.  These are the steps initially taken to install NixOS, though once the config is setup it can just be re-used for future re-installs if needed. This assumes you have booted into a NixOS install image from a USB stick and that we will be using systemd-boot.  Following the [manual installation steps](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual):

```shell
sudo -i
```

## Disk Setup

Creates 3 partitions on the virtual drive, one for EFI Boot, one for swap, and one for the primary partition.

```
parted /dev/vda -- mklabel gpt
parted /dev/vda -- mkpart primary 512MB -8GB
parted /dev/vda -- mkpart primary linux-swap -8GB 100%
parted /dev/vda -- mkpart ESP fat32 1MB 512MB
parted /dev/vda -- set 3 esp on
mkfs.ext4 -L nixos /dev/vda1
mkswap -L swap /dev/vda2
mkfs.fat -F 32 -n boot /dev/vda3
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/vda2
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
git clone https://github.com/billimek/dotfiles.git
```

I will then copy in the new machine basic config into a new machine folder and setup the configuration.nix in root. I will then replace the generated config with the new setup.

```shell
cd dotfiles
mkdir -p hosts/home
mv ../configuration.nix hosts/home/default.nix
mv ../hardware-configuration.nix hosts/home/hardware-configuration.nix
vim hosts/home/default.nix
> add all modules/profiles as required.
mv ./* ..
mv ./.* ..
cd ../
rm -rf dotfiles
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
atuin sync
```

### kubeconfig

```shell
mkdir -p ~/.kube
op document get --vault kubernetes 'k3s.yaml' --out-file ~/.kube/config
```
