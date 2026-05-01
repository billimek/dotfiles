# Claude Code CLI configuration
#
# The binary is installed outside Nix (`curl -fsSL https://claude.ai/install.sh | bash`)
# so it can auto-update. Nix manages settings.json, the starship-driven
# statusline, and (via agent-instructions.nix) ~/.claude/CLAUDE.md.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.claude-code;

  defaultSettings = {
    model = "opusplan";
    effortLevel = "medium";
    remoteControlAtStartup = true;
    includeCoAuthoredBy = false;

    permissions.defaultMode = "plan";
    permissions.allow = [
      # Modern CLI (per AGENTS.md preferences)
      "Bash(rg:*)"
      "Bash(fd:*)"
      "Bash(eza:*)"
      "Bash(jq:*)"
      "Bash(yq:*)"
      "Bash(procs:*)"

      # POSIX read-only
      "Bash(ls:*)"
      "Bash(cat:*)"
      "Bash(head:*)"
      "Bash(tail:*)"
      "Bash(wc:*)"
      "Bash(sort:*)"
      "Bash(uniq:*)"
      "Bash(grep:*)"
      "Bash(find:*)"
      "Bash(tree:*)"
      "Bash(file:*)"
      "Bash(stat:*)"
      "Bash(which:*)"
      "Bash(type:*)"
      "Bash(command -v:*)"
      "Bash(test:*)"
      "Bash(env)"
      "Bash(printenv:*)"

      # Read-only git
      "Bash(git status:*)"
      "Bash(git diff:*)"
      "Bash(git log:*)"
      "Bash(git show:*)"
      "Bash(git rev-parse:*)"
      "Bash(git remote -v)"
      "Bash(git remote get-url:*)"
      "Bash(git config --get:*)"
      "Bash(git config -l)"
      "Bash(git config --list)"
      "Bash(git ls-files:*)"
      "Bash(git ls-tree:*)"
      "Bash(git blame:*)"
      "Bash(git stash list)"
      "Bash(git stash show:*)"

      # Read-only nix
      "Bash(nix eval:*)"
      "Bash(nix flake show:*)"
      "Bash(nix flake metadata:*)"
      "Bash(nix-store --query:*)"
      "Bash(nix derivation show:*)"
      "Bash(nix path-info:*)"

      # macOS diagnostic (read-only; harmless on Linux hosts)
      "Bash(log show:*)"
      "Bash(log stream:*)"
      "Bash(lsappinfo list:*)"
      "Bash(lsappinfo front:*)"
      "Bash(dig:*)"
      "Bash(system_profiler:*)"

      # Comma wrapper for ad-hoc tools NOT already on PATH via cli.nix/bat.nix.
      # Blanket-allowing `Bash(,:*)` would let `, rm ...` bypass the deny-list,
      # so we keep this list narrow to read-only inspection helpers.
      "Bash(, exiftool:*)"
      "Bash(, mediainfo:*)"
      "Bash(, ffprobe:*)"
      "Bash(, pandoc:*)"
      "Bash(, hexyl:*)"
      "Bash(, xxd:*)"
      "Bash(, glow:*)"

      # Python via nix-shell. Running python is arbitrary code execution by
      # definition, so this expands trust by roughly the same amount as
      # allowing `python3 -c ...` directly. The deny-list (rm/git push/nh) is
      # the real safety boundary.
      "Bash(nix-shell -p python3:*)"
      "Bash(nix-shell -p python3Packages.*:*)"
      "Bash(nix-shell -p 'python3.withPackages*':*)"
      "Bash(nix-shell -p \"python3.withPackages*\":*)"

      # Web
      "WebSearch"
      "WebFetch"
    ];
  };

  statuslinePackage = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = with pkgs; [
      jq
      starship
      coreutils
      gawk
    ];
    text = ''
      payload=$(cat)
      cwd=$(printf '%s' "$payload" | jq -r '.workspace.current_dir // .cwd // "."')
      pct=$(printf '%s' "$payload" | jq -r '.context_window.used_percentage // 0' | awk '{printf "%d", $1+0}')
      [ -z "$pct" ] && pct=0

      CLAUDE_MODEL=$(printf '%s' "$payload" | jq -r '.model.display_name // .model.id // ""')
      CLAUDE_OUTPUT_STYLE=$(printf '%s' "$payload" | jq -r '.output_style.name // ""')
      CLAUDE_VERSION=$(printf '%s' "$payload" | jq -r '.version // ""')
      export CLAUDE_MODEL CLAUDE_OUTPUT_STYLE CLAUDE_VERSION
      export CLAUDE_CTX_PCT="$pct"

      filled=$(( pct / 10 ))
      if [ "$filled" -gt 10 ]; then filled=10; fi
      empty=$(( 10 - filled ))
      bar=""
      i=0; while [ "$i" -lt "$filled" ]; do bar="''${bar}█"; i=$((i+1)); done
      i=0; while [ "$i" -lt "$empty"  ]; do bar="''${bar}░"; i=$((i+1)); done
      export CLAUDE_CTX_BAR="$bar"

      cd "$cwd" 2>/dev/null || true
      STARSHIP_CONFIG="${config.home.homeDirectory}/.claude/starship.toml" exec starship prompt
    '';
  };

  starshipConfig = (pkgs.formats.toml { }).generate "claude-starship.toml" {
    add_newline = false;
    command_timeout = 500;
    format =
      "$directory$git_branch$git_status$nix_shell$kubernetes"
      + "\${custom.model}\${custom.output_style}"
      + "\${custom.ctx_low}\${custom.ctx_med}\${custom.ctx_high}";

    directory = {
      format = "[$path]($style) ";
      truncation_length = 3;
    };
    git_branch = {
      symbol = " ";
      format = "[$symbol$branch]($style) ";
    };
    git_status.format = "([\\[$all_status$ahead_behind\\]]($style) )";
    nix_shell = {
      symbol = " ";
      format = "[$symbol$state]($style) ";
    };
    kubernetes = {
      symbol = "⎈ ";
      disabled = false;
    };

    custom = {
      model = {
        when = ''[ -n "$CLAUDE_MODEL" ]'';
        command = ''printf '%s' "$CLAUDE_MODEL"'';
        format = "[🤖 $output]($style) ";
        style = "bold cyan";
        shell = [
          "bash"
          "--noprofile"
          "--norc"
        ];
      };
      output_style = {
        when = ''[ -n "$CLAUDE_OUTPUT_STYLE" ] && [ "$CLAUDE_OUTPUT_STYLE" != "default" ]'';
        command = ''printf '%s' "$CLAUDE_OUTPUT_STYLE"'';
        format = "[$output]($style) ";
        style = "italic yellow";
        shell = [
          "bash"
          "--noprofile"
          "--norc"
        ];
      };
      ctx_low = {
        when = ''[ "$CLAUDE_CTX_PCT" -lt 50 ]'';
        command = ''printf 'ctx %s %s%%' "$CLAUDE_CTX_BAR" "$CLAUDE_CTX_PCT"'';
        format = "[$output]($style)";
        style = "green";
        shell = [
          "bash"
          "--noprofile"
          "--norc"
        ];
      };
      ctx_med = {
        when = ''[ "$CLAUDE_CTX_PCT" -ge 50 ] && [ "$CLAUDE_CTX_PCT" -lt 80 ]'';
        command = ''printf 'ctx %s %s%%' "$CLAUDE_CTX_BAR" "$CLAUDE_CTX_PCT"'';
        format = "[$output]($style)";
        style = "yellow";
        shell = [
          "bash"
          "--noprofile"
          "--norc"
        ];
      };
      ctx_high = {
        when = ''[ "$CLAUDE_CTX_PCT" -ge 80 ]'';
        command = ''printf 'ctx %s %s%%' "$CLAUDE_CTX_BAR" "$CLAUDE_CTX_PCT"'';
        format = "[$output]($style)";
        style = "bold red";
        shell = [
          "bash"
          "--noprofile"
          "--norc"
        ];
      };
    };
  };
in
{
  options.modules.claude-code = {
    enable = lib.mkEnableOption "Claude Code CLI" // {
      default = true;
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = defaultSettings;
      description = ''
        Contents of ~/.claude/settings.json. Defaults cover model, plan-mode
        startup, and a read-only command allowlist; per-host modules can
        override individual fields with lib.mkForce.
      '';
    };

    statusline.enable = lib.mkEnableOption "starship-driven Claude statusline" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables.CLAUDE_CODE_SUBAGENT_MODEL = "sonnet";

    programs.claude-code = {
      enable = true;
      # manage outside of nix for faster updates (curl -fsSL https://claude.ai/install.sh | bash)
      package = null;

      settings =
        cfg.settings
        // lib.optionalAttrs cfg.statusline.enable {
          statusLine = {
            type = "command";
            command = "${config.home.homeDirectory}/.claude/statusline-command.sh";
            padding = 0;
          };
        };
    };

    home.file.".claude/statusline-command.sh" = lib.mkIf cfg.statusline.enable {
      source = "${statuslinePackage}/bin/claude-statusline";
      executable = true;
    };

    home.file.".claude/starship.toml" = lib.mkIf cfg.statusline.enable {
      source = starshipConfig;
    };
  };
}
