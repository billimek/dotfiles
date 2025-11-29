Leveraging nix, nix-os, nix-darwin, and home-manager to apply machine and home configurations

![](https://imgur.com/ISNnzgN.png)

## Structure

```
.
├── flake.nix                  # Simplified entry point using flake-parts
├── flake-module.nix           # Flake-parts module with autowiring logic
├── flake.lock                 # Lockfile (updated daily via GitHub Actions)
├── lib/
│   └── autowire.nix           # Helper functions for auto-discovering configs/modules
├── configurations/            # Host-specific configurations
│   ├── nixos/                 # NixOS hosts
│   │   ├── nas/               # NixOS NAS server (Proxmox, ZFS, Samba, etc.)
│   │   ├── home/              # NixOS VM running in NAS
│   │   └── cloud/             # NixOS VM running in Oracle Cloud
│   └── darwin/                # macOS hosts
│       ├── Jeffs-M3Pro.nix    # Personal MacBook Pro
│       └── work-laptop.nix    # Work MacBook Pro
├── users/                     # Home Manager configurations by user
│   ├── jeff/
│   │   ├── default.nix        # Shared jeff user settings
│   │   └── hosts/             # Per-host configurations
│   │       ├── Jeffs-M3Pro.nix
│   │       ├── work-laptop.nix
│   │       ├── home.nix
│   │       └── cloud.nix
│   └── nix/
│       ├── default.nix        # Shared nix user settings
│       └── hosts/
│           └── nas.nix
├── modules/                   # Reusable modules with enable options
│   ├── nixos/                 # NixOS modules (base, zfs, docker, etc.)
│   ├── darwin/                # Darwin modules (base, homebrew)
│   └── home/                  # Home Manager modules (cli, fish, dev, etc.)
├── overlays/                  # Custom package overlays
├── packages/                  # Custom packages not in nixpkgs
├── secrets/                   # Encrypted secrets directory (git-crypt)
└── secrets.nix                # Encrypted secrets file (git-crypt)
```

### Key Concepts

- **Autowiring**: Configurations and modules are auto-discovered based on directory structure
- **Modular Architecture**: All features are opt-in modules with `enable` options
- **Separation of Concerns**: Configurations (what to enable) vs Modules (how it works)
- **User-first Home Manager**: Organized as `users/<user>/hosts/<host>.nix`

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
