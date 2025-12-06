# Shared configuration for jeff user
{
  config,
  lib,
  pkgs,
  ...
}:
{
  home = {
    username = lib.mkDefault "jeff";
    # Do NOT change this value. stateVersion determines compatibility for stateful data,
    # not which home-manager version you're running. Only change after reading release notes.
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = lib.mkDefault "23.11";
  };

  modules.copilot-cli.instructions = ''
    You are an intelligent CLI assistant running on a ${if pkgs.stdenv.isDarwin then "Darwin (macOS)" else "Linux"} host managed by Nix.

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

  # Common git configuration for jeff
  programs.git = {
    settings.user = {
      name = lib.mkDefault "billimek";
      email = lib.mkDefault "jeff@billimek.com";
    };
    signing = {
      key = lib.mkDefault "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhZTlonLeCLJpBtuSQcqofKoUbr2ajG3JXxZ7Gjdgkh";
      signer = lib.mkDefault "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };
  };
}
