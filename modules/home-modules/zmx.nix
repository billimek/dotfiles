{ ... }: {
  flake.homeManagerModules.zmx =
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
            "nas.shell"
            "cloud.shell"
          ];
          description = "Pinned zmx session names for the zc picker (live remote sessions are merged in)";
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
            # Fixed agent socket held open by the ssh control master
            if set -q ZMX_SESSION
              set -gx SSH_AUTH_SOCK ~/.ssh/agent.sock
            end
          '';
        })

        # Everywhere: zc session picker
        (lib.mkIf cfg.enable {
          programs.fish.functions.zc = {
            description = "Connect to a remote zmx session via autossh (fzf picker)";
            body = ''
              set -l pinned ${lib.concatStringsSep " " (map lib.escapeShellArg cfg.sessions)}
              set -l hosts nas cloud
              set -l tmp (mktemp -d)
              for h in $hosts
                ssh -o BatchMode=yes -o ConnectTimeout=3 $h zmx list --short > $tmp/$h 2>/dev/null &
              end
              wait
              set -l live
              for h in $hosts
                for n in (cat $tmp/$h)
                  if string match -q "$h.*" $n
                    set -a live $n
                  else
                    set -a live $h.$n
                  end
                end
              end
              rm -rf $tmp
              set -l all (printf '%s\n' $pinned $live | sort -u)
              set -l news
              for h in $hosts
                set -a news "+ new $h"
              end
              set -l choice (printf '%s\n' $all $news | fzf --header="Select zmx session" --layout=reverse --height=40%)
              test -n "$choice"; or return
              if string match -q '+ new *' $choice
                set -l h (string replace '+ new ' "" $choice)
                set -l i 2
                while contains $h.shell$i $all
                  set i (math $i + 1)
                end
                set choice $h.shell$i
              end
              autossh -M 0 $choice
            '';
          };
        })
      ];
    };
}
