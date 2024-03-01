# NAS running under NixOS

![](https://i.imgur.com/T5n1Tcw.png)

'nas' is a dedicated server with the following configuration:

* Motherboard: Supermicro X11SCA-F
* CPU: Intel i5-9500T
* Memory: 128GB
* Disk:
  * Boot - 500GB nvme SSD 
  * 'ssdtank' 4 SSD (2 1TB and 2 500GB (one of the SSDs is an nvme))
  * LSI 9211-8i HBA:
    * 'tank' - 8 HDD (4 14TB and 2 18TB)
* NIC:
  * built-in 1GB IPMI
  * built-in 1GB LAN
  * Mellanox MT26448 PCI 10GB SFP+

### supermicro X11SCA-F notes

* in order to have working IPMI video and iGPU passthrough in the BIOS configuration set `Primary Display : PCI` and `Internal Graphics: Enable` (**more to add to this laster as experiments continue**)
* in IPMI, set fan control to "standard speed" to avoid blasting the fans at 100%
* to adjust the fan speed alerting thresholds for larger slower fans, use `sudo ipmitool sensor thresh CPU_FAN1 lower 300 300 400` to set the lower, upper, and critical thresholds for the fan speed sensor

It is installed with the NixOS iso installation media.  These are the steps initially taken to install NixOS, though once the config is setup it can just be re-used for future re-installs if needed. This assumes you have booted into a NixOS install image from a USB stick and that we will be using systemd-boot.  Following the [manual installation steps](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual):

root shell and set password to continue from ssh session:

```shell
sudo -i
passwd
```

## Disk Setup

Creates 3 partitions on the virtual drive, one for EFI Boot, one for swap, and one for the primary partition.

```shell
parted /dev/nvme1n1 -- mklabel gpt
parted /dev/nvme1n1 -- mkpart primary 512MB -8GB
parted /dev/nvme1n1 -- mkpart primary linux-swap -8GB 100%
parted /dev/nvme1n1 -- mkpart ESP fat32 1MB 512MB
parted /dev/nvme1n1 -- set 3 esp on
mkfs.ext4 -L nixos /dev/nvme1n1p1
mkswap -L swap /dev/nvme1n1p2
mkfs.fat -F 32 -n boot /dev/nvme1n1p3
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/nvme1n1p2
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
chown -R nix:users .
reboot
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
