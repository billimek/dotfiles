{ ... }:
{
  flake.homeManagerModules.secretspec =
    # secretspec-wrapped launch for MCP servers that need a secret at process
    # start (e.g. `GRAFANA_SERVICE_ACCOUNT_TOKEN`).
    #
    # Replaces the `$(op read ...)` command-substitution pattern for servers
    # that can use it (it still lives inline for HTTP-transport servers like
    # leanix in hosts/home/jeff/work-laptop.nix — see below). That pattern
    # resolved the secret once at `nh home switch` time and baked the
    # plaintext value into ~/.claude.json via `claude mcp add`, with a rotated
    # or locked-vault token silently becoming an empty string (`2>/dev/null`).
    # secretspec instead resolves the secret at process launch and injects it
    # into the child's environment only, never into ~/.claude.json. A cached
    # provider alias (see `providers.cached` below) serves repeat reads from
    # the login keychain for `cacheMaxAge` so `op` isn't contacted, and no
    # 1Password biometric prompt is raised, on every MCP server launch.
    #
    # Deliberately narrow: this does NOT replace `secrets.nix` (git-crypt,
    # eval-time values) or opnix (`services.onepassword-secrets`, runtime
    # NixOS service secrets delivered as owned files). Neither of those fits
    # secretspec's model — see modules/home-modules/secretspec.nix history /
    # CLAUDE.md "Secrets" section for why.
    #
    # HTTP-transport MCP servers (secret riding in an Authorization header
    # string, e.g. leanix) cannot use this either: there is no child process
    # for `secretspec run` to wrap. Those stay on `op read`.
    {
      config,
      lib,
      pkgs,
      pkgs-unstable,
      ...
    }:
    let
      cfg = config.modules.secretspec;

      secretspecToml = (pkgs.formats.toml { }).generate "secretspec.toml" {
        project = {
          name = "dotfiles";
          revision = "1.0";
        };
        # `op` alone would hit `op`/the 1Password desktop integration on
        # every process launch, i.e. a biometric prompt every time Claude
        # Code (re)starts an MCP server. `cached` serves repeat reads from
        # the system keyring for `cacheMaxAge` instead, so `op` is only
        # actually contacted once per that window.
        providers = {
          op = "onepassword://${cfg.vault}";
          op-cache = "keyring://secretspec/cache/{project}/{profile}/{key}";
          cached = {
            fallback = [ "op" ];
            cache = {
              provider = "op-cache";
              max_age = cfg.cacheMaxAge;
            };
          };
        };
        profiles.default = lib.mapAttrs (_: s: {
          description = s.description;
          ref = {
            item = s.item;
            field = s.field;
          };
        }) cfg.secrets;
      };
    in
    {
      options.modules.secretspec = {
        enable = lib.mkEnableOption "secretspec-wrapped secret injection for MCP servers";

        vault = lib.mkOption {
          type = lib.types.str;
          default = "nix";
          description = "1Password vault secretspec resolves `ref`-addressed secrets from.";
        };

        cacheMaxAge = lib.mkOption {
          type = lib.types.str;
          default = "12h";
          description = ''
            How long a resolved secret is served from the local keyring cache
            before `op` is contacted again. secretspec duration syntax: a
            number plus `s`/`m`/`h`/`d`/`w`.
          '';
        };

        secrets = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                description = lib.mkOption {
                  type = lib.types.str;
                  description = "Human-readable purpose, shown by `secretspec check`.";
                };
                item = lib.mkOption {
                  type = lib.types.str;
                  description = "1Password item title (or UUID) in `vault`.";
                };
                field = lib.mkOption {
                  type = lib.types.str;
                  description = "1Password field label on `item`.";
                };
              };
            }
          );
          default = { };
          description = ''
            Secrets declared in secretspec.toml, keyed by the env var name the
            wrapped process should see. Each maps onto an existing 1Password
            item/field rather than secretspec's default convention storage.
          '';
        };

        configPath = lib.mkOption {
          type = lib.types.str;
          readOnly = true;
          default = "${config.xdg.configHome}/secretspec/secretspec.toml";
          description = "Absolute path to the generated secretspec.toml.";
        };

        wrapArgs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          readOnly = true;
          default = [
            "--file"
            cfg.configPath
            "run"
            "--provider"
            "cached"
            # secretspec 0.17's default `require_reason = "agents"` policy
            # refuses to resolve secrets for an agent-launched process (which
            # is exactly what an MCP server is) without one.
            "--reason"
            "Claude Code MCP server launch"
            "--"
          ];
          description = ''
            Argument prefix that wraps a command with `secretspec run`. Use as
            `command = lib.getExe pkgs-unstable.secretspec; args = cfg.wrapArgs ++ [ realCommand ... ];`
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs-unstable.secretspec ];
        xdg.configFile."secretspec/secretspec.toml".source = secretspecToml;
      };
    };
}
