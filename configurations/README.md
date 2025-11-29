# Configurations

Host-specific system configurations for NixOS and nix-darwin.

Each machine has its own configuration file or directory. These configurations enable the appropriate modules from `modules/` and reference Home Manager configurations from `users/` for user-level packages and dotfiles.

## NixOS Configurations

- [nas](nixos/nas/README.md) - Dedicated NixOS server
- [home](nixos/home/README.md) - NixOS VM running in Proxmox on NAS
- [cloud](nixos/cloud/README.md) - NixOS VM running in Oracle Cloud

## Darwin (macOS) Configurations

- [work-laptop](darwin/work-laptop.md) - Work MacBook Pro
- [Jeffs-M3Pro](darwin/Jeffs-M3Pro.md) - Jeff's personal MacBook Pro

## Structure

```
configurations/
├── nixos/
│   ├── <hostname>/
│   │   ├── default.nix           # Host configuration
│   │   ├── hardware-configuration.nix  # Hardware-specific config
│   │   └── README.md             # Host documentation
│   └── ...
└── darwin/
    ├── <hostname>.nix            # Host configuration
    └── <hostname>.md             # Host documentation
```

## Rebuilding

```shell
# NixOS (run on the NixOS machine)
sudo nixos-rebuild switch --flake .#<hostname>
# or with nh:
nh os switch

# macOS (nix-darwin)
darwin-rebuild switch --flake .#<hostname>

# Home Manager (standalone, run separately)
home-manager switch --flake .#<user@hostname>
# or with nh:
nh home switch
```
