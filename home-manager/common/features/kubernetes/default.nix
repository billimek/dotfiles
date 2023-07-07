{ pkgs, ... }: {
  home.packages = with pkgs; [
    fluxcd # flux CLI
    go-task
    k9s # kubernetes viewer tool
    kubectl
    kubernetes-helm
    kustomize
  ];
}
