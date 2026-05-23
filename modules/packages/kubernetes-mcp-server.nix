{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.kubernetes-mcp-server = pkgs.callPackage ../../packages/kubernetes-mcp-server.nix { };
    };
}
