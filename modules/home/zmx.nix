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
        "nas.files"
        "nas.shell"
        "cloud.shell"
        "cloud.deploy"
      ];
      description = "Predefined zmx session names for the zmx-connect picker";
    };
  };

  config = lib.mkMerge [
    # Linux-only: install zmx binary + fish completions
    (lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
      home.packages = [ inputs.zmx.packages.${pkgs.system}.default ];

      programs.fish.interactiveShellInit = lib.mkAfter ''
        if type -q zmx
          zmx completions fish | source
        end
      '';
    })

    # Everywhere: zmx-connect fzf session picker
    (lib.mkIf (cfg.sessions != [ ]) {
      programs.fish.functions.zmx-connect = {
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
