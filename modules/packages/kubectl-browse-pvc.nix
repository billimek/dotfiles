{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.kubectl-browse-pvc = pkgs.callPackage ../../packages/kubectl-browse-pvc.nix { };
    };
}
