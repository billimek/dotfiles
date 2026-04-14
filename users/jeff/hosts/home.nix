# Home Manager configuration for jeff on home (VM)
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
    # dev.enable = true;  # commented out in original
    kubernetes.enable = true;

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
