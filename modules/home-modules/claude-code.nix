{ ... }:
{
  flake.homeManagerModules.claude-code =
    # Claude Code CLI configuration
    #
    # The binary is installed outside Nix (`curl -fsSL https://claude.ai/install.sh | bash`)
    # so it can auto-update. Nix manages settings.json, the starship-driven
    # statusline, and (via agent-instructions.nix) ~/.claude/CLAUDE.md.
    #
    # settings.json is COPIED during activation rather than symlinked from the
    # store. Claude Code's settings writer opens the file with O_NOFOLLOW and
    # refuses to write through a symlink at all ("Refusing to write through
    # symlink"), so a store symlink there makes every runtime settings write
    # fail silently. That is not a bug awaiting a fix: both upstream reports
    # (anthropics/claude-code#15786, #55485) were closed as not planned, and it
    # is why the wider nix community copies this file too. Copying keeps nix as
    # the source of truth while leaving the file writable, which also lets
    # Claude Code complete its one-time org-default reconciliation instead of
    # retrying it (and resetting `model`) on every single startup.
    #
    # Trade-off: runtime changes made via /config, /effort, or "add to user
    # settings" are reverted on the next home-manager switch. Anything meant to
    # be durable belongs in `defaultSettings` below.
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.modules.claude-code;

      defaultMcpServers = {
        mcp-nixos = {
          command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
          args = [ ];
        };
        kubernetes = {
          command = "${pkgs.kubernetes-mcp-server}/bin/kubernetes-mcp-server";
          args = [ ];
        };
        flux = {
          command = "${pkgs.flux-operator-mcp}/bin/flux-operator-mcp";
          args = [
            "serve"
            "--read-only"
          ];
          env = [ "KUBECONFIG=${config.home.homeDirectory}/.kube/config" ];
        };
        github = {
          type = "http";
          url = "https://api.githubcopilot.com/mcp";
          # gh auth token evaluated at activation time so it stays current
          headers = [ "Authorization: Bearer $(${pkgs.gh}/bin/gh auth token 2>/dev/null)" ];
        };
      };

      defaultSettings = {
        model = "sonnet";
        effortLevel = "medium";
        remoteControlAtStartup = true;
        includeCoAuthoredBy = false;
        agentPushNotifEnabled = true;
        inputNeededNotifEnabled = true;
        tui = "fullscreen";
        outputStyle = "Concise";

        # Auto mode became the Pro/Max/Team default 2026-08-14; the classifier
        # gates destructive actions instead of prompting. Note: broad
        # permissions.allow rules below are dormant under auto and reactivate
        # in other modes.
        permissions.defaultMode = "auto";
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

          # Write git (requires explicit user instruction to commit/push)
          "Bash(git add:*)"
          "Bash(git commit:*)"
          "Bash(git push:*)"

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

          # MCP — whole-server approve for servers that cannot write
          "mcp__mcp-nixos"
          "mcp__flux"
          "mcp__grafana"
          "mcp__victorialogs"

          # MCP — kubernetes read-only tools only (write tools stay gated)
          "mcp__kubernetes__configuration_contexts_list"
          "mcp__kubernetes__configuration_view"
          "mcp__kubernetes__events_list"
          "mcp__kubernetes__namespaces_list"
          "mcp__kubernetes__nodes_log"
          "mcp__kubernetes__nodes_stats_summary"
          "mcp__kubernetes__nodes_top"
          "mcp__kubernetes__pods_get"
          "mcp__kubernetes__pods_list"
          "mcp__kubernetes__pods_list_in_namespace"
          "mcp__kubernetes__pods_log"
          "mcp__kubernetes__pods_top"
          "mcp__kubernetes__resources_get"
          "mcp__kubernetes__resources_list"
        ];

        autoMode.allow = [
          "$defaults"
          "Run git push when the user explicitly asks to push"
        ];
      };

      statuslinePackage = pkgs.writeShellApplication {
        name = "claude-statusline";
        runtimeInputs = with pkgs; [
          jq
          starship
          coreutils
          gawk
          findutils
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

          cost_usd=$(printf '%s' "$payload" | jq -r '.cost.total_cost_usd // 0' | awk '{printf "%.2f", $1+0}')
          export CLAUDE_COST_USD="$cost_usd"

          lim5h=$(printf '%s' "$payload" | jq -r '.rate_limits.five_hour.used_percentage // empty' | awk 'NF{printf "%d", $1+0}')
          lim7d=$(printf '%s' "$payload" | jq -r '.rate_limits.seven_day.used_percentage // empty' | awk 'NF{printf "%d", $1+0}')
          export CLAUDE_LIMIT_5H_PCT="$lim5h"
          export CLAUDE_LIMIT_7D_PCT="$lim7d"

          session_id=$(printf '%s' "$payload" | jq -r '.session_id // ""')
          agent_count=0
          count_file="/tmp/claude-subagents-$session_id.count"
          if [ -n "$session_id" ] && [ -f "$count_file" ] \
             && [ -n "$(find "$count_file" -mmin -1 2>/dev/null)" ]; then
            agent_count=$(cat "$count_file" 2>/dev/null || echo 0)
          fi
          export CLAUDE_AGENT_COUNT="$agent_count"

          # Count unreconciled settings.json stashes left by the activation
          # script (see home.activation.claudeSettings). -maxdepth 1 is load
          # bearing: /reconcile-claude-settings moves processed stashes into
          # reconciled/ to clear this indicator, and without it they would keep
          # being counted and the warning would never go away.
          drift_count=0
          drift_dir="$HOME/.claude/settings-drift"
          if [ -d "$drift_dir" ]; then
            drift_count=$(find "$drift_dir" -maxdepth 1 -type f -name '*.json' 2>/dev/null | wc -l | awk '{print $1}')
          fi
          export CLAUDE_SETTINGS_DRIFT="$drift_count"

          cd "$cwd" 2>/dev/null || true
          STARSHIP_CONFIG="${config.home.homeDirectory}/.claude/starship.toml" exec starship prompt
        '';
      };

      subagentStatuslinePackage = pkgs.writeShellApplication {
        name = "claude-subagent-statusline";
        runtimeInputs = with pkgs; [
          jq
          coreutils
          gawk
          findutils
        ];
        text = ''
          payload=$(cat)
          session_id=$(printf '%s' "$payload" | jq -r '.session_id // ""')
          [ -z "$session_id" ] && exit 0

          # Try array mode first (documented: tasks[] with full list per render).
          count=$(printf '%s' "$payload" \
            | jq -r 'if (.tasks|type) == "array"
                     then [.tasks[] | select(.status != "completed"
                                          and .status != "done"
                                          and .status != "error"
                                          and .status != "cancelled")] | length
                     else empty end' 2>/dev/null || true)

          if [ -z "$count" ]; then
            # Per-row fallback: touch a marker file per task id, count fresh ones.
            task_id=$(printf '%s' "$payload" | jq -r '.id // .task.id // ""')
            dir="/tmp/claude-subagents-$session_id"
            mkdir -p "$dir"
            [ -n "$task_id" ] && : > "$dir/$task_id"
            count=$(find "$dir" -type f -mmin -0.1 2>/dev/null | wc -l | awk '{print $1}')
          fi

          out="/tmp/claude-subagents-$session_id.count"
          printf '%s' "$count" > "$out.tmp" && mv "$out.tmp" "$out"

          # Output label for the agent panel row.
          printf '%s' "$payload" | jq -r '.label // .name // ""'
        '';
      };

      starshipConfig = (pkgs.formats.toml { }).generate "claude-starship.toml" {
        add_newline = false;
        command_timeout = 500;
        format =
          "$directory$git_branch$git_status$nix_shell$kubernetes"
          + "\${custom.model}\${custom.output_style}\${custom.settings_drift}\${custom.agents}\${custom.cost}"
          + "\${custom.ctx_low}\${custom.ctx_med}\${custom.ctx_high}"
          + "\${custom.limit_5h_low}\${custom.limit_5h_med}\${custom.limit_5h_high}"
          + "\${custom.limit_7d_low}\${custom.limit_7d_med}\${custom.limit_7d_high}";

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
          # Unreconciled settings.json drift. `nh` hides activation output unless
          # run with -v, so the stash warning printed during the switch is never
          # actually seen; surface it here instead, where /reconcile-claude-settings
          # is also the obvious next action.
          settings_drift = {
            when = ''[ "$CLAUDE_SETTINGS_DRIFT" -gt 0 ]'';
            command = ''printf 'cfg-drift %s' "$CLAUDE_SETTINGS_DRIFT"'';
            format = "[$output]($style) ";
            style = "bold yellow";
            shell = [
              "bash"
              "--noprofile"
              "--norc"
            ];
          };
          agents = {
            when = ''[ "$CLAUDE_AGENT_COUNT" -gt 0 ]'';
            command = ''printf '⚙ %s' "$CLAUDE_AGENT_COUNT"'';
            format = "[$output]($style) ";
            style = "bold magenta";
            shell = [
              "bash"
              "--noprofile"
              "--norc"
            ];
          };
          cost = {
            when = ''awk "BEGIN{exit !($CLAUDE_COST_USD > 0)}"'';
            command = ''printf '$%s' "$CLAUDE_COST_USD"'';
            format = "[$output]($style) ";
            style = "bold green";
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
          limit_5h_low = {
            when = ''[ -n "$CLAUDE_LIMIT_5H_PCT" ] && [ "$CLAUDE_LIMIT_5H_PCT" -lt 50 ]'';
            command = ''printf '5h %s%%' "$CLAUDE_LIMIT_5H_PCT"'';
            format = "[ $output]($style)";
            style = "green";
            shell = [
              "bash"
              "--noprofile"
              "--norc"
            ];
          };
          limit_5h_med = {
            when = ''[ -n "$CLAUDE_LIMIT_5H_PCT" ] && [ "$CLAUDE_LIMIT_5H_PCT" -ge 50 ] && [ "$CLAUDE_LIMIT_5H_PCT" -lt 80 ]'';
            command = ''printf '5h %s%%' "$CLAUDE_LIMIT_5H_PCT"'';
            format = "[ $output]($style)";
            style = "yellow";
            shell = [
              "bash"
              "--noprofile"
              "--norc"
            ];
          };
          limit_5h_high = {
            when = ''[ -n "$CLAUDE_LIMIT_5H_PCT" ] && [ "$CLAUDE_LIMIT_5H_PCT" -ge 80 ]'';
            command = ''printf '5h %s%%' "$CLAUDE_LIMIT_5H_PCT"'';
            format = "[ $output]($style)";
            style = "bold red";
            shell = [
              "bash"
              "--noprofile"
              "--norc"
            ];
          };
          limit_7d_low = {
            when = ''[ -n "$CLAUDE_LIMIT_7D_PCT" ] && [ "$CLAUDE_LIMIT_7D_PCT" -lt 50 ]'';
            command = ''printf '7d %s%%' "$CLAUDE_LIMIT_7D_PCT"'';
            format = "[ $output]($style)";
            style = "green";
            shell = [
              "bash"
              "--noprofile"
              "--norc"
            ];
          };
          limit_7d_med = {
            when = ''[ -n "$CLAUDE_LIMIT_7D_PCT" ] && [ "$CLAUDE_LIMIT_7D_PCT" -ge 50 ] && [ "$CLAUDE_LIMIT_7D_PCT" -lt 80 ]'';
            command = ''printf '7d %s%%' "$CLAUDE_LIMIT_7D_PCT"'';
            format = "[ $output]($style)";
            style = "yellow";
            shell = [
              "bash"
              "--noprofile"
              "--norc"
            ];
          };
          limit_7d_high = {
            when = ''[ -n "$CLAUDE_LIMIT_7D_PCT" ] && [ "$CLAUDE_LIMIT_7D_PCT" -ge 80 ]'';
            command = ''printf '7d %s%%' "$CLAUDE_LIMIT_7D_PCT"'';
            format = "[ $output]($style)";
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

            Written by copy during activation, not symlinked, so Claude Code can
            write to the file. This means the file is overwritten on every
            switch and any runtime changes to it are lost.
          '';
        };

        mcpServers = lib.mkOption {
          type = lib.types.attrsOf lib.types.attrs;
          default = defaultMcpServers;
          description = ''
            MCP servers to register via `claude mcp add --scope user` during
            home-manager activation. Claude Code reads these from ~/.claude.json,
            not settings.json, so they must be registered imperatively.
            Stdio servers need {command, args}; HTTP servers need {type="http", url}.
          '';
        };

        extraMcpServers = lib.mkOption {
          type = lib.types.attrsOf lib.types.attrs;
          default = { };
          description = ''
            Per-host MCP servers merged on top of mcpServers. Lets a single host
            register an extra server without redefining the shared defaults.
          '';
        };

        statusline.enable = lib.mkEnableOption "starship-driven Claude statusline" // {
          default = true;
        };
      };

      config = lib.mkIf cfg.enable {
        home.sessionVariables = {
          CLAUDE_CODE_SUBAGENT_MODEL = "sonnet";
        };

        programs.claude-code = {
          enable = true;
          # manage outside of nix for faster updates (curl -fsSL https://claude.ai/install.sh | bash)
          package = null;

          # Deliberately left unset: home-manager only creates the
          # ~/.claude/settings.json symlink when this is non-empty, and Claude
          # Code cannot write through a symlink. home.activation.claudeSettings
          # below copies the same JSON into place instead.
          settings = { };
        };

        home.activation.claudeSettings =
          let
            settingsJson = (pkgs.formats.json { }).generate "claude-code-settings.json" (
              {
                "$schema" = "https://json.schemastore.org/claude-code-settings.json";
              }
              // cfg.settings
              // lib.optionalAttrs cfg.statusline.enable {
                # `padding` is deliberately omitted. It is optional in Claude
                # Code's schema and it strips the key when it rewrites the file,
                # so emitting `padding = 0` would make the live file differ from
                # nix after every rewrite and trip the drift check below forever.
                statusLine = {
                  type = "command";
                  command = "${config.home.homeDirectory}/.claude/statusline-command.sh";
                };
                subagentStatusLine = {
                  type = "command";
                  command = "${config.home.homeDirectory}/.claude/subagent-statusline.sh";
                };
              }
            );
            claudeDir = lib.escapeShellArg "${config.home.homeDirectory}/.claude";
            target = lib.escapeShellArg "${config.home.homeDirectory}/.claude/settings.json";
            driftDir = lib.escapeShellArg "${config.home.homeDirectory}/.claude/settings-drift";
          in
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            $DRY_RUN_CMD mkdir -p ${claudeDir}

            # This file is overwritten on every switch, so any setting Claude
            # Code wrote at runtime (/config, /effort, "add to user settings")
            # would vanish here. Stash a copy first whenever the live file
            # differs semantically from what we are about to install, so the
            # change can be reconciled into defaultSettings rather than lost.
            # `jq -S` normalises key order and whitespace so Claude Code merely
            # rewriting the file is not mistaken for a real change. It does not
            # hide added or removed keys, so avoid emitting keys Claude Code
            # strips as defaults (see the `padding` note above) or this fires
            # on every switch.
            if [ -f ${target} ] && [ \
                 "$(${pkgs.jq}/bin/jq -S . ${target} 2>/dev/null)" \
                 != "$(${pkgs.jq}/bin/jq -S . ${settingsJson})" ]; then
              stamp="$(date +%Y%m%dT%H%M%S)"
              $DRY_RUN_CMD mkdir -p ${driftDir}
              $DRY_RUN_CMD cp ${target} ${driftDir}/"$stamp".json
              echo "claude-code: settings.json had runtime changes; saved ${driftDir}/$stamp.json" >&2
              echo "claude-code: run /reconcile-claude-settings in the dotfiles repo to fold them in" >&2
            fi

            # `rm -f` first: the target may still be a store symlink from an
            # older generation, and `install` would follow it into the
            # read-only store instead of replacing it. Mode 644 (not the
            # store's 444) is what keeps the file writable by Claude Code.
            $DRY_RUN_CMD rm -f ${target}
            $DRY_RUN_CMD install -m 644 ${settingsJson} ${target}
          '';

        home.activation.claudeMcpServers =
          let
            # Claude Code binary installs outside Nix; activation PATH won't find it
            claudeBin = lib.escapeShellArg "${config.home.homeDirectory}/.local/bin/claude";
            allServers = cfg.mcpServers // cfg.extraMcpServers;
          in
          lib.hm.dag.entryAfter [ "writeBoundary" ] (
            lib.optionalString (allServers != { }) (
              "if [ -x ${claudeBin} ]; then\n"
              + lib.concatStringsSep "\n" (
                lib.mapAttrsToList (
                  name: server:
                  let
                    n = lib.escapeShellArg name;
                    # Double-quote env so bash evaluates any $(...) (e.g. `op read`) at
                    # activation time, mirroring the headers treatment below.
                    envFlags = lib.concatMapStringsSep " " (e: ''-e "${e}"'') (server.env or [ ]);
                    # Double-quote headers so bash evaluates any $(...) at activation time
                    headerFlags = lib.concatMapStringsSep " " (h: ''-H "${h}"'') (server.headers or [ ]);
                    addCmd =
                      if (server.type or "") == "http" then
                        "${claudeBin} mcp add -s user --transport http ${n} ${lib.escapeShellArg server.url}${
                          lib.optionalString (headerFlags != "") " ${headerFlags}"
                        }"
                      else
                        "${claudeBin} mcp add -s user ${n} ${lib.escapeShellArg server.command} ${
                          lib.optionalString (envFlags != "") "${envFlags} "
                        }-- ${lib.escapeShellArgs server.args}";
                  in
                  "  $DRY_RUN_CMD ${claudeBin} mcp remove -s user ${n} >/dev/null 2>&1 || true\n  $DRY_RUN_CMD ${addCmd}"
                ) allServers
              )
              + "\nfi\n"
            )
          );

        home.file.".claude/statusline-command.sh" = lib.mkIf cfg.statusline.enable {
          source = "${statuslinePackage}/bin/claude-statusline";
          executable = true;
        };

        home.file.".claude/subagent-statusline.sh" = lib.mkIf cfg.statusline.enable {
          source = "${subagentStatuslinePackage}/bin/claude-subagent-statusline";
          executable = true;
        };

        home.file.".claude/starship.toml" = lib.mkIf cfg.statusline.enable {
          source = starshipConfig;
        };
      };
    };
}
