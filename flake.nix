{
  description = "billimek nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Flake framework
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";

    hardware.url = "github:nixos/nixos-hardware";
    nix-colors.url = "github:misterio77/nix-colors";
    talhelper.url = "github:budimanjojo/talhelper";
    opnix.url = "github:brizzbuzz/opnix";
    nvf.url = "github:notashelf/nvf";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      inherit (self) outputs;

      mkNixos =
        modules:
        nixpkgs.lib.nixosSystem {
          inherit modules;
          specialArgs = {
            inherit inputs outputs;
          };
        };

      mkHome =
        modules: pkgs:
        home-manager.lib.homeManagerConfiguration {
          inherit modules pkgs;
          extraSpecialArgs = {
            inherit inputs outputs;
          };
        };

      mkDarwin =
        system: modules:
        nix-darwin.lib.darwinSystem {
          inherit system modules;
          specialArgs = {
            inherit inputs outputs;
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      # Per-system outputs
      perSystem =
        { pkgs, system, ... }:
        {
          # Custom packages accessible via 'nix build', 'nix shell', etc
          packages = import ./pkgs { inherit pkgs; };

          # Formatter for nix files, available via 'nix fmt'
          formatter = pkgs.nixfmt-rfc-style;
        };

      # Flake-wide outputs
      flake = {
        # Custom overlays
        overlays = import ./overlays { inherit inputs; };

        # Reusable modules
        nixosModules = import ./modules/nixos;
        homeManagerModules = import ./modules/home-manager;

        # NixOS configurations
        nixosConfigurations = {
          nas = mkNixos [ ./hosts/nas ];
          home = mkNixos [ ./hosts/home ];
          cloud = mkNixos [ ./hosts/cloud ];
        };

        # Darwin (macOS) configurations
        darwinConfigurations = {
          work-laptop = mkDarwin "aarch64-darwin" [ ./hosts/work_laptop ];
          Jeffs-M3Pro = mkDarwin "aarch64-darwin" [ ./hosts/jeffs_laptop ];
        };

        # Standalone Home Manager configurations
        homeConfigurations = {
          "nix@nas" = mkHome [ ./home-manager/nix_nas.nix ] nixpkgs.legacyPackages."x86_64-linux";
          "jeff@home" = mkHome [ ./home-manager/jeff_home.nix ] nixpkgs.legacyPackages."x86_64-linux";
          "jeff@cloud" = mkHome [ ./home-manager/jeff_cloud.nix ] nixpkgs.legacyPackages."aarch64-linux";
          "jeff@work-laptop" = mkHome [ ./home-manager/jeff_work_laptop.nix ] nixpkgs.legacyPackages."aarch64-darwin";
          "jeff@Jeffs-M3Pro" = mkHome [ ./home-manager/jeffs_laptop.nix ] nixpkgs.legacyPackages."aarch64-darwin";
          "root@truenas" = mkHome [ ./home-manager/root_truenas.nix ] nixpkgs.legacyPackages."x86_64-linux";
        };
      };
    };
}
