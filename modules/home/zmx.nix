# zmx session persistence
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.modules.zmx;
in
{
  options.modules.zmx = {
    enable = lib.mkEnableOption "zmx session persistence";

    sessions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "home.gitops"
        "home.nixos"
        "home.shell"
        "home.k9s"
        "nas.shell"
        "cloud.shell"
      ];
      description = "Predefined zmx session names for the zc picker";
    };
  };

  config = lib.mkMerge [
    # Install zmx binary + fish completions (both Linux and Darwin)
    (lib.mkIf cfg.enable {
      home.packages = [ inputs.zmx.packages.${pkgs.system}.default ];

      programs.fish.interactiveShellInit = lib.mkAfter ''
        if type -q zmx
          zmx completions fish | source
        end
        # Use stable symlink for SSH agent so forwarding survives session re-attach
        if set -q ZMX_SESSION
          set -gx SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock
        end
      '';
    })

    # Linux-only: cd / launch app on session creation
    (lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
      programs.fish.interactiveShellInit = lib.mkAfter ''
        switch "$ZMX_SESSION"
          case home.gitops
            cd ~/src/k8s-gitops
          case home.nixos
            cd /etc/nixos
          case home.k9s
            k9s
        end
      '';
    })

    # Everywhere: zc fzf session picker
    (lib.mkIf (cfg.sessions != [ ]) {
      programs.fish.functions.zc = {
        description = "Connect to a remote zmx session via autossh (fzf picker)";
        body = ''
          set -l sessions ${lib.concatStringsSep " " (map (s: lib.escapeShellArg s) cfg.sessions)}
          set -l choice (printf '%s\n' $sessions | fzf --header="Select zmx session" --layout=reverse --height=40%)
          if test -n "$choice"
            autossh -M 0 $choice
          end
        '';
      };
    })
  ];
}
