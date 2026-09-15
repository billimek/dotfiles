# Home Manager configuration for jeff on home (VM)
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Enable optional feature modules
  modules = {
    # dev.enable = true;  # commented out in original
    kubernetes.enable = true;
    zmx.enable = true;

    # HTTP-transport MCP server whose secret URL is itself the credential
    # (no separate header/token) -- resolved via `op read` at activation.
    claude-code.extraMcpServers.homeassistant = {
      type = "http";
      url = "$(${pkgs._1password-cli}/bin/op read op://nix/ha-mcp/url)";
    };

    zellij = {
      defaultLayout = "home";
      layouts.home = ''
        layout {
          default_tab_template {
            pane size=1 borderless=true {
              plugin location="tab-bar"
            }
            children
            pane size=2 borderless=true {
              plugin location="status-bar"
            }
          }
          tab name="k8s-gitops" focus=true {
            pane cwd="/home/jeff/src/k8s-gitops"
          }
          tab name="nixos" {
            pane cwd="/etc/nixos"
          }
          tab name="nas" {
            pane command="ssh" {
              args "-A" "nix@nas"
            }
          }
          tab name="shell" {
            pane
          }
        }
      '';
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
