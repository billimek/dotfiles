{
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
            "kubectl debug -it --context $CONTEXT -n=$NAMESPACE $POD --target=$NAME --image=nicolaka/netshoot:v0.12 --share-processes -- bash"
          ];
        };
      };
    };
  };
}
