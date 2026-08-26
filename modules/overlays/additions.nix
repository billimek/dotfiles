{ ... }:
{
  flake.overlays.additions = final: _prev: {
    kubectl-browse-pvc = final.callPackage ../../packages/kubectl-browse-pvc.nix { };
    kubernetes-mcp-server = final.callPackage ../../packages/kubernetes-mcp-server.nix { };
    flux-operator-mcp = final.callPackage ../../packages/flux-operator-mcp.nix { };
    mcp-victorialogs = final.callPackage ../../packages/mcp-victorialogs.nix { };
    topf = final.callPackage ../../packages/topf.nix { };
  };
}
