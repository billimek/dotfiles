# Hosts

Main system level NixOS configuration for various hosts

Each machine has its own directory where main config and hardware specific to it can be defined. There is also a [common](common) directory where global and optional configurations are defined.

These configurations generally reference a [home-manager](../home-manager) config to add in user-level packages and dotfiles configuration.

##  Configurations

- [home](home/README.md) (NixOS VM running in NAS)
- [cloud](cloud/README.md) (NixOS VM running in Oracle Cloud)
- [work_laptop](work_laptop/README.md) nix-darwin running on a MacBook Pro
- [jeffs_laptop](jeffs_laptop/README.md) nix-darwin running on a Macbook Pro
