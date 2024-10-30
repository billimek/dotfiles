# Bootstrapping NixOS on 'k3s-0' kubernetes control plane node

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

## Proxmox VM config

```ini
agent: 1
bios: ovmf
boot: order=scsi0;ide2;net0
cores: 2
cpu: host
efidisk0: ssdtank-proxmox:vm-300-disk-0,efitype=4m,size=1M
ide2: tank-proxmox:iso/latest-nixos-minimal-x86_64-linux.iso,media=cdrom,size=1094512K
machine: q35
memory: 4096
meta: creation-qemu=8.1.5,ctime=1730250507
name: k3s-0
net0: virtio=BC:24:11:C9:F7:88,bridge=brk8s20,firewall=1
numa: 0
ostype: l26
scsi0: ssdtank-proxmox:vm-300-disk-1,discard=on,iothread=1,size=200G,ssd=1
scsihw: virtio-scsi-single
sockets: 1
```

It is installed with the NixOS iso installation media.  These are the steps initially taken to install NixOS, though once the config is setup it can just be re-used for future re-installs if needed. This assumes you have booted into a NixOS install image from a USB stick and that we will be using systemd-boot.  Following the [manual installation steps](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual):

Set the 'nixos' live-install password so we can continue from a remote ssh session by logging in to the set IP of the machine

```shell
passwd
ip addr show
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

... after reboot, login as root on the console and set the password for the nix user

```shell
<login as root from the console>
passwd nix
```

## First Run

Here is where I will normally try and setup all the hardware and import the profiles/modules I want from this repo. Since I use the minimal install, I will kick things off like so:

```shell
ssh -A nix@<ip of host>
nix-shell -p git vim git-crypt
cd /etc/nixos
# these should no longer be needed if we already have the proper configurations already defined in the repo
sudo mv configuration.nix hardware-configuration.nix /tmp/
sudo git clone https://github.com/billimek/dotfiles.git .
sudo chown -R nix:users .
git-crypt unlock ~/.ssh/git-crypt-dotfiles.key # this came from an early undocumented step of copying the key to the host
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
