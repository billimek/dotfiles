{ ... }:
{
  flake.homeManagerModules.ssh =
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
          enableDefaultConfig = false;
          settings = {
            "*" = {
              AddKeysToAgent = "yes";
            };
            "cloud" = {
              Hostname = "cloud";
              User = "jeff";
              ForwardAgent = "yes";
              SetEnv = {
                is_vscode = "1";
              };
            };
            "home" = {
              Hostname = "home";
              User = "jeff";
              ForwardAgent = "yes";
              SetEnv = {
                is_vscode = "1";
              };
            };
            "nas" = {
              Hostname = "nas";
              User = "nix";
              ForwardAgent = "yes";
              SetEnv = {
                is_vscode = "1";
              };
            };
            # zmx session hosts -- e.g. "ssh home.shell" attaches to zmx session "home.shell"
            "home.*" = {
              Hostname = "home";
              User = "jeff";
              ForwardAgent = "yes";
              ControlMaster = "auto";
              ControlPath = "~/.ssh/cm-%r@%h:%p";
              ControlPersist = "10m";
              ServerAliveInterval = 60;
              ServerAliveCountMax = 3;
              RequestTTY = "yes";
              RemoteCommand = "zmx attach %n";
            };
            "nas.*" = {
              Hostname = "nas";
              User = "nix";
              ForwardAgent = "yes";
              ControlMaster = "auto";
              ControlPath = "~/.ssh/cm-%r@%h:%p";
              ControlPersist = "10m";
              ServerAliveInterval = 60;
              ServerAliveCountMax = 3;
              RequestTTY = "yes";
              RemoteCommand = "zmx attach %n";
            };
            "cloud.*" = {
              Hostname = "cloud";
              User = "jeff";
              ForwardAgent = "yes";
              ControlMaster = "auto";
              ControlPath = "~/.ssh/cm-%r@%h:%p";
              ControlPersist = "10m";
              ServerAliveInterval = 60;
              ServerAliveCountMax = 3;
              RequestTTY = "yes";
              RemoteCommand = "zmx attach %n";
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
    };
}
