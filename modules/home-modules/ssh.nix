{ ... }:
{
  flake.homeManagerModules.ssh =
    # SSH configuration
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.modules.ssh;
      localAgent = "%d/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
      # Darwin clients forward the 1Password agent to a fixed remote socket owned by the control master
      agentFwd =
        user:
        if pkgs.stdenv.isDarwin then
          { RemoteForward = "/home/${user}/.ssh/agent.sock \"${localAgent}\""; }
        else
          { ForwardAgent = "yes"; };
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
            # zmx session hosts -- e.g. "ssh nas.shell" attaches to zmx session "nas.shell"
            "nas.*" = agentFwd "nix" // {
              Hostname = "nas";
              User = "nix";
              ControlMaster = "auto";
              ControlPath = "~/.ssh/cm-%r@%h:%p";
              ControlPersist = "10m";
              ServerAliveInterval = 60;
              ServerAliveCountMax = 3;
              RequestTTY = "yes";
              RemoteCommand = "zmx attach %n";
            };
            "cloud.*" = agentFwd "jeff" // {
              Hostname = "cloud";
              User = "jeff";
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
