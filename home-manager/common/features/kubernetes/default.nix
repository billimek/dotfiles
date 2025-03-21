{ pkgs, nixpkgs, inputs, ... }:
{
  imports = [ ./k9s.nix ];
  home.packages = with pkgs; [
    fluxcd # flux CLI
    go-task # task runner
    kail # kubernetes tail
    ktop # kubernetes top
    kubectl # kubernetes CLI
    kubectl-doctor # kubernetes doctor
    kubectl-example # output example kubernetes types
    kubectl-view-allocations # view kubernetes allocations
    kubectl-view-secret # view kubernetes secrets without piping and decoding
    pkgs.unstable.kubecolor # colorize kubectl output
    kubernetes-helm # helm CLI
    kustomize # kustomize CLI for sadists
    talhelper # talos helper
    talosctl # talos CLI
  ];
}
