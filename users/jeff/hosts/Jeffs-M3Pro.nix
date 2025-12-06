# Home Manager configuration for jeff on Jeffs-M3Pro (personal MacBook)
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../default.nix
  ];

  # Enable optional feature modules
  modules = {
    dev.enable = true;
    kubernetes.enable = true;
    copilot-cli.instructions = ''
      You are an intelligent CLI assistant running on a Darwin (macOS) host managed by Nix.

      # Environment & Shell
      - **Shell**: The user uses `fish`. ALWAYS generate fish-compatible commands.
        - Use `(cmd)` for substitution, not `$(cmd)`.
        - Use `set -gx VAR val` for exports.
        - Use `and`/`or` for logic.
      - **Packages**:
        - If a tool is missing, suggest using `nix-shell -p <pkg>` or the comma wrapper `, <cmd>`.

      # Preferred Tools
      The following modern tools are available and preferred over their traditional counterparts:
      - **Search**: `rg` (ripgrep) instead of `grep`.
      - **Find**: `fd` instead of `find`.
      - **List**: `eza` instead of `ls`.
      - **Processes**: `procs` instead of `ps`.
      - **Text Replace**: `sd` instead of `sed`.
      - **Data**: `jq` for JSON, `yq` for YAML.
    '';
  };

  home = {
    homeDirectory = "/Users/${config.home.username}";
    packages = with pkgs; [
      terminal-notifier # send notifications to macOS notification center
    ];
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
        extraOptions = {
          IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
        };
      };
    };
  };

  programs.fish = {
    shellAbbrs = rec { };
    shellAliases = { };
    shellInit = ''
      # set -gx SSH_AUTH_SOCK '$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock'
      # set -gx FLAKE "$HOME/src/dotfiles"
      set -gx NH_FLAKE "$HOME/src/dotfiles"
    '';

    loginShellInit = ''for p in (string split " " $NIX_PROFILES); fish_add_path --prepend --move $p/bin; end'';

    interactiveShellInit =
      # fix brew path (should not be needed but somehow is?)
      ''
        eval (/opt/homebrew/bin/brew shellenv)
      '';
  };
}
