# Zellij terminal multiplexer
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.zellij;
in
{
  options.modules.zellij = {
    enable = lib.mkEnableOption "zellij" // {
      default = true;
    };

    defaultLayout = lib.mkOption {
      type = lib.types.str;
      default = "default";
      description = "Default layout to use when starting zellij";
    };

    layouts = lib.mkOption {
      type = lib.types.attrsOf lib.types.lines;
      default = { };
      description = "Zellij layouts as raw KDL strings, keyed by layout name";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      # Don't auto-start zellij on shell open -- conflicts with tmux
      enableFishIntegration = false;

      settings = {
        default_shell = "fish";
        default_layout = cfg.defaultLayout;
      };

      layouts = cfg.layouts;

      extraConfig = ''
        // Pass stable SSH auth socket so reattached sessions find the 1Password agent
        env {
            SSH_AUTH_SOCK "$HOME/.ssh/ssh_auth_sock"
        }

        keybinds {
            // Remap Tab mode to Ctrl-a (tmux muscle memory)
            normal {
                unbind "Ctrl t"
                bind "Ctrl a" { SwitchToMode "Tab"; }
            }
            tab {
                unbind "Ctrl t"
                bind "Ctrl a" { SwitchToMode "Normal"; }
            }
            shared_except "locked" {
                bind "Shift Left"  { GoToPreviousTab; }
                bind "Shift Right" { GoToNextTab; }
            }
        }
      '';
    };
  };
}
