# Bootstrapping NixOS on 'k3s-f' kubernetes node

'k3s-f' is an intel N100 ['T9 Plus mini PC'](https://liliputing.com/t9-plus-is-a-palm-sized-pc-with-intel-n100-and-triple-display-support-for-117-and-up/) from China.

* CPU:
  * 4 Cores
* Memory:
  * 16GB
* Disk:
  * 1TB onboard ssd
* NIC:
  * 1GBe dual nic

It is installed with the NixOS iso installation media.  These are the steps initially taken to install NixOS, though once the config is setup it can just be re-used for future re-installs if needed. This assumes you have booted into a NixOS install image from a USB stick and that we will be using systemd-boot.  Following the [manual installation steps](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual):

Set the 'nixos' live-install password so we can continue from a remote ssh session by logging in to the set IP of the machine

```shell
passwd
ip addr show
```

## Disk Setup

Creates 3 partitions on the virtual drive, one for EFI Boot, one for swap, and one for the primary partition.

```shell
ssh nixos@<ip address of host>
sudo -i
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart primary 512MB -8GB
parted /dev/nvme0n1 -- mkpart primary linux-swap -8GB 100%
parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB
parted /dev/nvme0n1 -- set 3 esp on
mkfs.ext4 -L nixos /dev/nvme0n1p1
mkswap -L swap /dev/nvme0n1p2
mkfs.fat -F 32 -n boot /dev/nvme0n1p3
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/nvme0n1p2
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
sudo rm configuration.nix hardware-configuration.nix
sudo git clone https://github.com/billimek/dotfiles.git .
```

Make any edits where necessary or desired, then build the configuration and _set the nix user password_.  Once all is 'clean', it should be possible to reboot and login as the nix user as a complete system.

```shell
sudo sh -c "cd /etc/nixos && git pull && nixos-rebuild switch"
passwd nix
reboot
```

I will then be able to update the nixos-configuration repo in github and just pull/rebuild as needed on the machine. 

```shell
sudo sh -c "cd /etc/nixos && git pull && nixos-rebuild switch"
```
