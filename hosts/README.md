# Hosts

Host-specific system and Home Manager configurations.

Each machine has its own configuration file or directory. Hosts enable
the appropriate feature modules from `modules/` and are wired up by
`modules/wiring/hosts.nix` (the central registry). See top-level
`CLAUDE.md` for the overall layout.

## NixOS Hosts

- [nas](nixos/nas/README.md) — Dedicated NixOS server
- [home](nixos/home/README.md) — NixOS VM running in Proxmox on NAS
- [cloud](nixos/cloud/README.md) — NixOS VM running in Oracle Cloud

## Darwin (macOS) Hosts

- `work-laptop` — Work MacBook Pro
- `Jeffs-M3Pro` — Jeff's personal MacBook Pro

See [darwin/README.md](darwin/README.md) for macOS bootstrap and rebuild
instructions.

## Home Manager Configurations

Per-user Home Manager configs live under `home/<user>/`. Shared
per-user settings are in `home/<user>/default.nix`; per-host overrides
are in `home/<user>/<hostname>.nix`. Both are threaded into the HM
generation by `modules/wiring/hosts.nix`.

## Structure

```
hosts/
├── nixos/
│   └── <hostname>/
│       ├── default.nix                 # Host configuration
│       ├── hardware-configuration.nix  # Hardware-specific config
│       └── README.md                   # Host documentation
├── darwin/
│   └── <hostname>.nix                  # Host configuration
└── home/
    └── <user>/
        ├── default.nix                 # Shared per-user HM config
        └── <hostname>.nix              # Per-host HM overrides
```

## Rebuilding

```fish
# NixOS (run on the NixOS machine)
sudo nixos-rebuild switch --flake .#<hostname>
# or with nh:
nh os switch

# macOS (nix-darwin)
darwin-rebuild switch --flake .#<hostname>
# or with nh:
nh darwin switch

# Home Manager (standalone)
home-manager switch --flake .#<user>@<hostname>
# or with nh:
nh home switch
```

## Adding a New Host

1. Create the host file(s) under `hosts/{nixos,darwin,home/<user>}/`.
2. Add a one-line entry to `modules/wiring/hosts.nix` so the host is
   exposed as a flake output.
