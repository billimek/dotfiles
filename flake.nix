{
  description = "billimek nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nh_darwin.url = "github:ToyVo/nh_plus";

    # for VSCode remote-ssh
    nix-ld-vscode = {
      url = "github:scottstephens/nix-ld-vscode/main";
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
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      nixpkgs-unstable,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      # Supported systems for your flake packages, shell, etc.
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;

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
    in
    {
      # Your custom packages
      # Acessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system: import ./pkgs { pkgs = nixpkgs.legacyPackages.${system}; });

      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;
      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeManagerModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        nas = mkNixos [ ./hosts/nas ];
        # VMs
        home = mkNixos [ ./hosts/home ];
        cloud = mkNixos [ ./hosts/cloud ];
      };

      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#<hostname>
      darwinConfigurations = {
        work-laptop = nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs outputs;
            pkgs-unstable = import nixpkgs-unstable {
              system = "aarch64-darwin";
              config.allowUnfree = true;
            };
          };
          system = "aarch64-darwin";
          modules = [ ./hosts/work_laptop ];
        };
        Jeffs-M3Pro = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            inherit inputs outputs;
            pkgs-unstable = import nixpkgs-unstable {
              system = "aarch64-darwin";
              config.allowUnfree = true;
            };
          };
          modules = [
            ./hosts/jeffs_laptop
            # nh_darwin.nixDarwinModules.default
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = {
        "nix@nas" = mkHome [ ./home-manager/nix_nas.nix ] nixpkgs.legacyPackages."x86_64-linux";
        # VMs
        "jeff@home" = mkHome [ ./home-manager/jeff_home.nix ] nixpkgs.legacyPackages."x86_64-linux";
        "jeff@cloud" = mkHome [ ./home-manager/jeff_cloud.nix ] nixpkgs.legacyPackages."aarch64-linux";
        # Laptops
        "jeff@work-laptop" = mkHome [
          ./home-manager/jeff_work_laptop.nix
        ] nixpkgs.legacyPackages."aarch64-darwin";
        "jeff@Jeffs-M3Pro" = mkHome [
          ./home-manager/jeffs_laptop.nix
        ] nixpkgs.legacyPackages."aarch64-darwin";
        # Other
        "root@truenas" = mkHome [ ./home-manager/root_truenas.nix ] nixpkgs.legacyPackages."x86_64-linux";
      };
    };
}
