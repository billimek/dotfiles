# perSystem's default `pkgs` arg is plain nixpkgs with no overlays -- unlike
# nixosConfigurations/darwinConfigurations/homeConfigurations, which all apply
# `outputs.overlays.*` (see nixos-modules/base.nix, darwin-modules/base.nix,
# home-modules/base.nix). Without this, `modules/packages/*.nix` couldn't
# reference `pkgs.<name>` for anything defined by the `additions` overlay and
# had to re-import each package's derivation file directly, duplicating the
# overlay's callPackage line. Overriding `_module.args.pkgs` here makes the
# perSystem `pkgs` consistent with every other pkgs instantiation in the flake.
{ inputs, self, ... }:
{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = builtins.attrValues self.overlays;
        config.allowUnfree = true;
      };
    };
}
