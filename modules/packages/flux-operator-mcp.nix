{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.flux-operator-mcp = pkgs.callPackage ../../packages/flux-operator-mcp.nix { };
    };
}
