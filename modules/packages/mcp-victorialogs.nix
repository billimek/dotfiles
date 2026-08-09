{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      # Sourced from the `additions` overlay (modules/overlays/additions.nix) so
      # there is a single place that defines this derivation.
      packages.mcp-victorialogs = pkgs.mcp-victorialogs;
    };
}
