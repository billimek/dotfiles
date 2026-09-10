{ ... }: {
  flake.homeManagerModules.kubernetes =
    # Kubernetes tools
    {
      config,
      lib,
      pkgs,
      pkgs-unstable,
      inputs,
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
          gum
          helmfile
          just
          kail
          kopiur
          ktop
          kubectl
          kubectl-browse-pvc
          kubectl-doctor
          kubectl-example
          kubectl-view-allocations
          kubectl-view-secret
          kubefetch
          minijinja
          kubecolor
          kubernetes-helm
          kustomize
          stern
          topf
          vals
          pkgs-unstable.talosctl
          inputs.sofka.packages.${pkgs.system}.default
          (wrapHelm kubernetes-helm {
            plugins = with pkgs.kubernetes-helmPlugins; [
              helm-diff
            ];
          })
        ];

        # sofka configuration -- replaces k9s (no home-manager module upstream,
        # so managed here directly). :debug on a pod/node covers the old k9s
        # debug-container plugin natively; no plugin needed.
        xdg.configFile."sofka/config.toml".text = ''
          [skin]
          name = "tokyo-night"

          [debug]
          image = "nicolaka/netshoot:v0.13"
        '';

        # `default_namespace` in config.toml is only a fallback for the very first
        # launch in a context -- after that sofka remembers the last namespace
        # picked per-context across restarts, so it can't reliably default to
        # all namespaces on its own. Force it with -A on every invocation instead.
        # Aliased to `k9s` since that's the muscle-memory name.
        programs.fish.shellAliases.k9s = "sofka -A";
      };
    };
}
