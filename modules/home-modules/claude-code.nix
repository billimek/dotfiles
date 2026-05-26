{ ... }:
{
  flake.homeManagerModules.claude-code =
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

      kubernetes-mcp-server = pkgs.callPackage ../../packages/kubernetes-mcp-server.nix { };
      flux-operator-mcp = pkgs.callPackage ../../packages/flux-operator-mcp.nix { };

      defaultMcpServers = {
        mcp-nixos = {
          command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
          args = [ ];
        };
        kubernetes = {
          command = "${kubernetes-mcp-server}/bin/kubernetes-mcp-server";
          args = [ ];
        };
        flux = {
          command = "${flux-operator-mcp}/bin/flux-operator-mcp";
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

          session_id=$(printf '%s' "$payload" | jq -r '.session_id // ""')
          agent_count=0
          count_file="/tmp/claude-subagents-$session_id.count"
          if [ -n "$session_id" ] && [ -f "$count_file" ] \
             && [ -n "$(find "$count_file" -mmin -1 2>/dev/null)" ]; then
            agent_count=$(cat "$count_file" 2>/dev/null || echo 0)
          fi
          export CLAUDE_AGENT_COUNT="$agent_count"

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
          + "\${custom.model}\${custom.output_style}\${custom.agents}\${custom.cost}"
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
              subagentStatusLine = {
                type = "command";
                command = "${config.home.homeDirectory}/.claude/subagent-statusline.sh";
                padding = 0;
              };
            };
        };

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
