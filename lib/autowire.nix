# Autowiring helper functions for auto-discovering configurations and modules
{ lib }:

let
  inherit (lib)
    filterAttrs
    mapAttrs'
    nameValuePair
    hasSuffix
    removeSuffix
    attrNames
    pathExists
    concatMapAttrs
    elem
    ;
  inherit (builtins) readDir;

  # Helper: Filter and map attributes in one pass
  mapFilterAttrs =
    pred: f: attrs:
    filterAttrs pred (mapAttrs' f attrs);

  # Helper: Check if path is a valid nix file or directory with default.nix
  isNixEntry =
    name: type:
    (type == "regular" && hasSuffix ".nix" name && name != "default.nix")
    || (type == "directory" && pathExists (name + "/default.nix"));

  # Helper: Get configuration name from filename or directory
  getConfigName =
    name: type: if type == "directory" then name else removeSuffix ".nix" name;

  # Safely read directory, returning empty set if path doesn't exist
  safeReadDir = dir: if pathExists dir then readDir dir else { };

  # Map hostnames to their system architecture
  hostToSystem =
    hostname:
    if elem hostname [
      "work-laptop"
      "Jeffs-M3Pro"
    ] then
      "aarch64-darwin"
    else if elem hostname [ "cloud" ] then
      "aarch64-linux"
    else
      "x86_64-linux";

in
{
  # Discover and import modules from a directory
  # Each .nix file or directory becomes a module export
  discoverModules =
    { dir }:
    mapFilterAttrs (_: v: v != null) (
      name: type:
      let
        isValidNixFile = type == "regular" && hasSuffix ".nix" name && name != "default.nix";
        isValidDir = type == "directory" && pathExists (dir + "/${name}/default.nix");
      in
      if isValidNixFile then
        nameValuePair (removeSuffix ".nix" name) (import (dir + "/${name}"))
      else if isValidDir then
        nameValuePair name (import (dir + "/${name}"))
      else
        nameValuePair "" null
    ) (safeReadDir dir);

  # Discover overlays from a directory
  discoverOverlays =
    { dir, inputs }:
    mapFilterAttrs (_: v: v != null) (
      name: type:
      let
        isValidNixFile = type == "regular" && hasSuffix ".nix" name && name != "default.nix";
      in
      if isValidNixFile then
        nameValuePair (removeSuffix ".nix" name) (import (dir + "/${name}") { inherit inputs; })
      else
        nameValuePair "" null
    ) (safeReadDir dir);

  # Discover packages from a directory
  # Each .nix file should be callPackage-compatible
  discoverPackages =
    { dir, pkgs }:
    mapFilterAttrs (_: v: v != null) (
      name: type:
      if type == "regular" && hasSuffix ".nix" name && name != "default.nix" then
        nameValuePair (removeSuffix ".nix" name) (pkgs.callPackage (dir + "/${name}") { })
      else
        nameValuePair "" null
    ) (safeReadDir dir);

  # Discover NixOS configurations
  # configurations/nixos/hostname/ -> nixosConfigurations.hostname
  discoverNixosConfigurations =
    {
      dir,
      inputs,
      outputs,
      nixosModules,
      specialArgs ? { },
    }:
    mapFilterAttrs (_: v: v != null) (
      name: type:
      let
        isValidDir = type == "directory" && pathExists (dir + "/${name}/default.nix");
      in
      if isValidDir then
        nameValuePair name (inputs.nixpkgs.lib.nixosSystem {
          modules = [
            (dir + "/${name}")
            # Import all discovered NixOS modules
            { imports = builtins.attrValues nixosModules; }
          ];
          specialArgs = specialArgs // {
            inherit inputs outputs;
          };
        })
      else
        nameValuePair "" null
    ) (safeReadDir dir);

  # Discover Darwin configurations
  # configurations/darwin/hostname.nix -> darwinConfigurations.hostname
  discoverDarwinConfigurations =
    {
      dir,
      inputs,
      outputs,
      darwinModules,
      specialArgs ? { },
    }:
    let
      nixpkgs-unstable = inputs.nixpkgs-unstable;
    in
    mapFilterAttrs (_: v: v != null) (
      name: type:
      let
        isValidNixFile = type == "regular" && hasSuffix ".nix" name && name != "default.nix";
        isValidDir = type == "directory" && pathExists (dir + "/${name}/default.nix");
        configName = removeSuffix ".nix" name;
        configPath = if isValidNixFile then dir + "/${name}" else dir + "/${name}";
      in
      if isValidNixFile || isValidDir then
        nameValuePair configName (inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            configPath
            # Import all discovered Darwin modules
            { imports = builtins.attrValues darwinModules; }
          ];
          specialArgs = specialArgs // {
            inherit inputs outputs;
            pkgs-unstable = import nixpkgs-unstable {
              system = "aarch64-darwin";
              config.allowUnfree = true;
            };
          };
        })
      else
        nameValuePair "" null
    ) (safeReadDir dir);

  # Discover Home Manager configurations
  # users/<user>/hosts/<host>.nix -> homeConfigurations."user@host"
  discoverHomeConfigurations =
    {
      dir,
      inputs,
      outputs,
      homeModules,
      extraSpecialArgs ? { },
    }:
    let
      nixpkgs = inputs.nixpkgs;

      # Get all user directories
      userDirs = filterAttrs (_: type: type == "directory") (safeReadDir dir);

      # For each user, get their host configurations
      userHostConfigs = concatMapAttrs (
        userName: _:
        let
          hostsDir = dir + "/${userName}/hosts";
          hostFiles = safeReadDir hostsDir;
        in
        mapFilterAttrs (_: v: v != null) (
          hostName: type:
          if type == "regular" && hasSuffix ".nix" hostName then
            let
              cleanHostName = removeSuffix ".nix" hostName;
              configName = "${userName}@${cleanHostName}";
              configPath = hostsDir + "/${hostName}";
              system = hostToSystem cleanHostName;
            in
            nameValuePair configName (inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.${system};
              modules = [
                configPath
                # Import all discovered home modules
                { imports = builtins.attrValues homeModules; }
              ];
              extraSpecialArgs = extraSpecialArgs // {
                inherit inputs outputs;
              };
            })
          else
            nameValuePair "" null
        ) hostFiles
      ) userDirs;
    in
    userHostConfigs;

  inherit hostToSystem;
}
