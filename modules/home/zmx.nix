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

  # Build an osascript command that opens one Ghostty tab per session,
  # using `initial input` so the command fires at terminal creation time
  # (no shell-readiness race condition).
  mkWorkspaceScript =
    sessions:
    let
      tabArgs = lib.concatMapStrings (
        s: ''-e 'new tab in w with configuration {initial input:"autossh -M 0 ${s}" & return}' \'' + "\n"
      ) sessions;
    in
    ''
      osascript \
          -e 'tell application "Ghostty"' \
          -e 'activate' \
          -e 'set w to front window' \
      ${tabArgs}    -e 'end tell'
    '';
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

    workspaceSessions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "home.gitops"
        "home.nixos"
        "home.shell"
        "nas.files"
      ];
      description = "Sessions opened as tabs by the zmx-workspace command (macOS/Ghostty only)";
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

    # Everywhere: zmx-connect fzf session picker (uses ash = autossh -M 0)
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

    # macOS-only: zmx-workspace opens Ghostty tabs via AppleScript
    (lib.mkIf (pkgs.stdenv.isDarwin && cfg.workspaceSessions != [ ]) {
      programs.fish.functions.zmx-workspace = {
        description = "Open Ghostty tabs for each workspace zmx session";
        body = mkWorkspaceScript cfg.workspaceSessions;
      };
    })
  ];
}
