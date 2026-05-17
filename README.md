Leveraging nix, nix-os, nix-darwin, and home-manager to apply machine and home configurations

![](https://i.imgur.com/eQyXtWk.png)

## Structure

Built on the **dendritic** flake-parts pattern via
[`mightyiam/import-tree`](https://github.com/mightyiam/import-tree):
`flake.nix` is just `mkFlake` + `(import-tree ./modules)`. Every `.nix`
file under `./modules/` is a flake-parts module that contributes to the
flake's outputs by option-merging.

```
.
├── flake.nix                  # mkFlake + (import-tree ./modules)
├── flake.lock                 # Lockfile (updated daily via GitHub Actions)
├── modules/                   # Everything here is a flake-parts module
│   ├── wiring/
│   │   ├── hosts.nix          # Central host registry (mkNixos / mkDarwin / mkHome)
│   │   ├── options.nix        # Option declarations for non-standard flake outputs
│   │   └── formatter.nix      # perSystem.formatter = nixfmt-rfc-style
│   ├── nixos-modules/         # NixOS feature modules (base, zfs, docker, ...)
│   ├── darwin-modules/        # Darwin feature modules (base, homebrew, determinate)
│   ├── home-modules/          # Home Manager feature modules (cli, fish, dev, ...)
│   ├── overlays/              # One flake-parts module per overlay
│   └── packages/              # perSystem.packages registrations
├── hosts/                     # NOT loaded by import-tree; referenced from modules/wiring/hosts.nix
│   ├── nixos/
│   │   ├── nas/               # NixOS NAS server (Proxmox, ZFS, Samba, etc.)
│   │   ├── home/              # NixOS VM running in NAS
│   │   └── cloud/             # NixOS VM running in Oracle Cloud
│   ├── darwin/
│   │   ├── Jeffs-M3Pro.nix    # Personal MacBook Pro
│   │   └── work-laptop.nix    # Work MacBook Pro
│   └── home/
│       ├── jeff/{default,Jeffs-M3Pro,work-laptop,home,cloud}.nix
│       └── nix/{default,nas}.nix
├── packages/                  # Custom callPackage-style derivations
└── secrets.nix                # Encrypted secrets file (git-crypt)
```

### Key Concepts

- **Dendritic pattern**: every `.nix` under `modules/` is a flake-parts module loaded recursively by `import-tree`
- **Modular architecture**: all features are opt-in modules with `enable` options
- **Explicit host registry**: `modules/wiring/hosts.nix` lists every nixos / darwin / home configuration (adding a host = one line)

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
