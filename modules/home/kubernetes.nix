# Kubernetes tools
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.kubernetes;
in
{
  options.modules.kubernetes = {
    enable = lib.mkEnableOption "kubernetes tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      fluxcd
      go-task
      helmfile
      kail
      ktop
      kubectl
      kubectl-browse-pvc
      kubectl-doctor
      kubectl-example
      kubectl-view-allocations
      kubectl-view-secret
      pkgs.unstable.kubefetch
      minijinja
      pkgs.unstable.kubecolor
      kubernetes-helm
      kustomize
      stern
      talhelper
      pkgs.unstable.talosctl
      (wrapHelm kubernetes-helm {
        plugins = with pkgs.kubernetes-helmPlugins; [
          helm-diff
        ];
      })
    ];

    # k9s configuration
    programs.k9s = {
      enable = true;
      plugin = {
        plugins = {
          # https://github.com/derailed/k9s/blob/master/plugins/debug-container.yaml
          debug = {
            shortCut = "Shift-D";
            description = "Add debug container";
            dangerous = true;
            scopes = [ "containers" ];
            command = "bash";
            background = false;
            args = [
              "-c"
              "kubectl debug -it --context $CONTEXT -n=$NAMESPACE $POD --target=$NAME --image=nicolaka/netshoot:v0.13 --share-processes -- bash"
            ];
          };
        };
      };
    };
  };
}
