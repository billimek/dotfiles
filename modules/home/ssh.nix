# SSH configuration
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.ssh;
in
{
  options.modules.ssh = {
    enable = lib.mkEnableOption "SSH configuration" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      # Disable deprecated default config - we set our own defaults in matchBlocks."*"
      enableDefaultConfig = false;
      matchBlocks."*" = {
        addKeysToAgent = "yes";
      };
      matchBlocks."cloud" = {
        hostname = "cloud";
        user = "jeff";
        forwardAgent = true;
        setEnv = {
          is_vscode = 1;
        };
      };
      matchBlocks."home" = {
        hostname = "home";
        user = "jeff";
        forwardAgent = true;
        setEnv = {
          is_vscode = 1;
        };
      };
      matchBlocks."nas" = {
        hostname = "nas";
        user = "nix";
        forwardAgent = true;
        setEnv = {
          is_vscode = 1;
        };
      };

      # zmx session hosts -- e.g. "ssh home.shell" attaches to zmx session "home.shell"
      matchBlocks."home.*" = {
        hostname = "home";
        user = "jeff";
        forwardAgent = true;
        requestTTY = "yes";
        remoteCommand = "zmx attach %n";
        extraOptions = {
          ControlMaster = "auto";
          ControlPath = "~/.ssh/cm-%r@%h:%p";
          ControlPersist = "10m";
        };
      };
      matchBlocks."nas.*" = {
        hostname = "nas";
        user = "nix";
        forwardAgent = true;
        requestTTY = "yes";
        remoteCommand = "zmx attach %n";
        extraOptions = {
          ControlMaster = "auto";
          ControlPath = "~/.ssh/cm-%r@%h:%p";
          ControlPersist = "10m";
        };
      };
      matchBlocks."cloud.*" = {
        hostname = "cloud";
        user = "jeff";
        forwardAgent = true;
        requestTTY = "yes";
        remoteCommand = "zmx attach %n";
        extraOptions = {
          ControlMaster = "auto";
          ControlPath = "~/.ssh/cm-%r@%h:%p";
          ControlPersist = "10m";
        };
      };
    };

    # place ~/.ssh/rc file
    home.file.".ssh/rc".text = ''
      if test "$SSH_AUTH_SOCK"; then
        ln -sf $SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock
      fi
      if read proto cookie && [ -n "$DISPLAY" ]; then
        if [ `echo $DISPLAY | cut -c1-10` = 'localhost:' ]; then
          # X11UseLocalhost=yes
          echo add unix:`echo $DISPLAY | cut -c11-` $proto $cookie
        else
          # X11UseLocalhost=no
          echo add $DISPLAY $proto $cookie
        fi | xauth -q -
      fi
    '';
  };
}
