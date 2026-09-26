# Home Manager configuration for jeff on Jeffs-M3Pro (personal MacBook)
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Enable optional feature modules
  modules = {
    dev.enable = true;
    kubernetes.enable = true;
    zmx.enable = true;

    claude-code.extraMcpServers.victorialogs = {
      command = lib.getExe pkgs.mcp-victorialogs;
      args = [ ];
      env = [
        "VL_INSTANCE_ENTRYPOINT=https://vlogs.eviljungle.com"
      ];
    };

    # HTTP-transport MCP server whose secret URL is itself the credential
    # (no separate header/token) -- resolved via `op read` at activation.
    claude-code.extraMcpServers.homeassistant = {
      type = "http";
      url = "$(${pkgs._1password-cli}/bin/op read op://nix/ha-mcp/url)";
    };

    claude-code.extraMcpServers.grafana = {
      command = lib.getExe pkgs.mcp-grafana;
      args = [ "--disable-write" ];
      env = [
        "GRAFANA_URL=https://grafana.eviljungle.com"
        "GRAFANA_SERVICE_ACCOUNT_TOKEN=$(${pkgs._1password-cli}/bin/op read op://nix/grafana-mcp/token)"
      ];
    };
  };

  home = {
    homeDirectory = "/Users/${config.home.username}";
    packages = with pkgs; [
      terminal-notifier # send notifications to macOS notification center
      _1password-cli
    ];
  };

  programs.ssh.settings."*" = {
    IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
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
