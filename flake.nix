{
  description = "billimek nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # for VSCode remote-ssh
    nix-ld-vscode = {
      url = "github:scottstephens/nix-ld-vscode/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware.url = "github:nixos/nixos-hardware";
    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, nixpkgs-unstable, ... }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      mkNixos = modules: nixpkgs.lib.nixosSystem {
        inherit modules;
        specialArgs = { inherit inputs outputs; };
      };        
      mkHome = modules: pkgs: home-manager.lib.homeManagerConfiguration {
        inherit modules pkgs;
        extraSpecialArgs = { inherit inputs outputs; };
      };

    in
    {
      # Your custom packages
      # Acessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs { inherit pkgs; }
      );
      # Devshell for bootstrapping
      # Acessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs; }
      );

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
        # VMs
        home = mkNixos [ ./hosts/home ];
        cloud = mkNixos [ ./hosts/cloud ];
        # k8s nodes
        k3s-f = mkNixos [ ./hosts/k3s-f ];
        k3s-g = mkNixos [ ./hosts/k3s-g ];
        k3s-h = mkNixos [ ./hosts/k3s-h ];
      };

      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#<hostname>
      darwinConfigurations = {
        work-laptop = nix-darwin.lib.darwinSystem {
          specialArgs = inputs;
          system = "aarch64-darwin";
          modules = [
            ./hosts/work_laptop
          ];
        };
        Jens-Air-M2 = nix-darwin.lib.darwinSystem {
          specialArgs = inputs;
          system = "aarch64-darwin";
          modules = [
            ./hosts/jens_laptop
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = {
        # VMs
        "jeff@home" = mkHome [ ./home-manager/jeff_home.nix ] nixpkgs.legacyPackages."x86_64-linux";
        "jeff@cloud" = mkHome [ ./home-manager/jeff_cloud.nix ] nixpkgs.legacyPackages."aarch64-linux";
        # k8s nodes
        "nix@k3s-f" = mkHome [ ./home-manager/nix_k3s-f.nix ] nixpkgs.legacyPackages."x86_64-linux";
        "nix@k3s-g" = mkHome [ ./home-manager/nix_k3s-g.nix ] nixpkgs.legacyPackages."x86_64-linux";
        "nix@k3s-h" = mkHome [ ./home-manager/nix_k3s-h.nix ] nixpkgs.legacyPackages."x86_64-linux";
        # Laptops
        "jeff@work-laptop" = mkHome [ ./home-manager/jeff_work_laptop.nix ] nixpkgs.legacyPackages."aarch64-darwin";
        "jeff@Jens-Air-M2" = mkHome [ ./home-manager/jens_laptop.nix ] nixpkgs.legacyPackages."aarch64-darwin";
        # Windows
        "jeff@honeypot" = mkHome [ ./home-manager/jeff_honeypot.nix ] nixpkgs.legacyPackages."x86_64-linux";
      };
    };
}
