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

  # Build a fish function body that opens one Ghostty tab per session.
  # Uses `new tab` → `delay 0.3` → `input text ... to (focused terminal of t)`
  # to reliably target each tab's own terminal surface.
  mkWorkspaceScript =
    sessions:
    let
      tabCmds = lib.concatMapStrings (s: ''
        set t to (new tab in w)
        delay 0.3
        input text "autossh -M 0 ${s}" & return to (focused terminal of t)
      '') sessions;
    in
    # Use printf to pipe AppleScript to osascript, avoiding fish heredoc quoting issues
    ''
      printf '%s' 'tell application "Ghostty"
          activate
          set w to front window
      ${tabCmds}end tell' | osascript
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
