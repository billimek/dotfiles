Leveraging nix, nix-os, nix-darwin, and home-manager to apply machine and home configurations

![](https://imgur.com/ISNnzgN.png)

## Structure

- [flake.nix](flake.nix) (Entrypoint for rebuilding via nixos-rebuild or home-manager)
- [flake.lock](flake.lock) (lockfile for current nix flake state, updated daily via [github action](.github/workflows/main.yml))
  - [home-manager](home-manager) (User level configuration per machine via home-manager)
  - [hosts](hosts/README.md) - (Definition of physical/virutal hosts)
    - [common](hosts/common) (Role definitions [Desktop, Laptop, Server])
      - [darwin](hosts/common/darwin) (global host configuration used across all darwin hosts)
      - [nixos](hosts/common/nixos) (global host configuration used across all NixOS hosts)
      - [optional](hosts/common/optional) (optional host configuration used as-needed per host)
    - [nas](hosts/nas/README.md) (NixOS NAS server)
    - [home](hosts/home/README.md) (NixOS VM running in NAS)
    - [cloud](hosts/cloud/README.md) (NixOS VM running in Oracle Cloud)
    - [jeffs_laptop](hosts/jeffs_laptop/README.md) (nix-darwin running on a MacBook Pro)
    - [work_laptop](hosts/work_laptop/README.md) (nix-darwin running on a MacBook Pro)
  - [modules](modules) (Custom NixOS and home-manager modules)
  - [overlays](overlays) (Custom overlays, primarily used for packages currently)
  - [pkgs](pkgs) (Custom Packages, mainly items not yet in official nixpkgs) 
- [shell.nix](shell.nix) (Shell for bootstrapping flake-enabled nix and home-manager)
- [nixpkgs.nix](nixpkgs.nix) (Used by shell.nix - useful to avoid using channels when using legacy nix commands)

## Background

Everyone keeps gushing about how amazing Nix is and I want to get in on the hype cycle

## Goals

- [x] Learn nix
- [x] Mostly reproduce features from my existing [dotfiles](https://github.com/billimek/dotfiles)
- [x] Replace existing ubunut-based 'home VM'
- [x] Expand usage to other shell environments such as WSL, Macbook, etc
- [x] handle secrets - ideally using 1Password and not SOPS - using git-crypt for now
- [x] try agenix for secrets handling
- [ ] introduce the concept of [impermanence](https://github.com/nix-community/impermanence) where appropriate

## References

- [Misterio77/nix-starter-config](https://github.com/Misterio77/nix-starter-configs)
- [How to learn Nix](https://ianthehenry.com/posts/how-to-learn-nix/)
- [home-manager](https://github.com/nix-community/home-manager)
- [Zero to Nix: Everything I Know About Nix & NixOS](https://chetanbhasin.com/articles/zero-to-nix-everything-i-know-about-nix-nixos)
- [Walkthrough of Nix Install and Setup on MacOS (YouTube)](https://www.youtube.com/watch?v=LE5JR4JcvMg)
- [NixOS as a server, part 1: Impermanence](https://guekka.github.io/nixos-server-1/)
- [budimanjojo/dotfiles](https://github.com/budimanjojo/dotfiles/tree/master/nixos)
- [wrmilling/nixos-configuration](https://github.com/wrmilling/nixos-configuration)
- [gshpychka/dotfiles-nix](https://github.com/gshpychka/dotfiles-nix)
- [wimpysworld/nix-config](https://github.com/wimpysworld/nix-config)

## Old Dotfiles

Old dotfiles are still accessible in [archive branch](https://github.com/billimek/dotfiles/tree/archive)
