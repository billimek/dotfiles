# Home Manager configuration for jeff on cloud (Oracle Cloud VM)
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

    # HTTP-transport MCP server whose secret URL is itself the credential
    # (no separate header/token) -- resolved via `op read` at activation.
    claude-code.extraMcpServers.homeassistant = {
      type = "http";
      url = "$(${pkgs._1password-cli}/bin/op read op://nix/ha-mcp/url)";
    };
  };

  home = {
    homeDirectory = "/home/${config.home.username}";
    packages = with pkgs; [
      _1password-cli
      nfs-utils
      calibre
    ];
  };
}
