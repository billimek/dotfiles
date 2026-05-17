{ ... }:
{
  flake.overlays.additions = final: _prev: {
    kubectl-browse-pvc = final.callPackage ../../packages/kubectl-browse-pvc.nix { };
  };
}
