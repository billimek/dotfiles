{ inputs, self, ... }:
let
  mkNixos =
    { system, hostPath }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
        outputs = self;
      };
      modules = [
        hostPath
        { imports = builtins.attrValues self.nixosModules; }
      ];
    };

  mkDarwin =
    { hostPath }:
    inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {
        inherit inputs;
        outputs = self;
        pkgs-unstable = import inputs.nixpkgs-unstable {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
      };
      modules = [
        hostPath
        { imports = builtins.attrValues self.darwinModules; }
      ];
    };

  mkHome =
    {
      system,
      hostPath,
      sharedPath,
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      modules = [
        sharedPath
        hostPath
        { imports = builtins.attrValues self.homeManagerModules; }
      ];
      extraSpecialArgs = {
        inherit inputs;
        outputs = self;
        pkgs-unstable = import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    };
in
{
  flake.nixosConfigurations = {
    nas = mkNixos {
      system = "x86_64-linux";
      hostPath = ../../hosts/nixos/nas;
    };
    cloud = mkNixos {
      system = "aarch64-linux";
      hostPath = ../../hosts/nixos/cloud;
    };
    home = mkNixos {
      system = "x86_64-linux";
      hostPath = ../../hosts/nixos/home;
    };
  };

  flake.darwinConfigurations = {
    Jeffs-M3Pro = mkDarwin { hostPath = ../../hosts/darwin/Jeffs-M3Pro.nix; };
    work-laptop = mkDarwin { hostPath = ../../hosts/darwin/work-laptop.nix; };
  };

  flake.homeConfigurations = {
    "jeff@cloud" = mkHome {
      system = "aarch64-linux";
      hostPath = ../../hosts/home/jeff/cloud.nix;
      sharedPath = ../../hosts/home/jeff/default.nix;
    };
    "jeff@home" = mkHome {
      system = "x86_64-linux";
      hostPath = ../../hosts/home/jeff/home.nix;
      sharedPath = ../../hosts/home/jeff/default.nix;
    };
    "jeff@Jeffs-M3Pro" = mkHome {
      system = "aarch64-darwin";
      hostPath = ../../hosts/home/jeff/Jeffs-M3Pro.nix;
      sharedPath = ../../hosts/home/jeff/default.nix;
    };
    "jeff@work-laptop" = mkHome {
      system = "aarch64-darwin";
      hostPath = ../../hosts/home/jeff/work-laptop.nix;
      sharedPath = ../../hosts/home/jeff/default.nix;
    };
    "nix@nas" = mkHome {
      system = "x86_64-linux";
      hostPath = ../../hosts/home/nix/nas.nix;
      sharedPath = ../../hosts/home/nix/default.nix;
    };
  };
}
