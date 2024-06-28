{ outputs, lib, ... }:
{
  programs.ssh = {
    enable = true;
    # add custom settings to config
    matchBlocks."cloud" = {
      hostname = "cloud.eviljungle.com";
      user = "jeff";
      forwardAgent = true;
      setEnv = {
        is_vscode = 1;
      };
    };
    matchBlocks."home" = {
      hostname = "home.home";
      user = "jeff";
      forwardAgent = true;
      setEnv = {
        is_vscode = 1;
      };
    };
    matchBlocks."nas-lan" = {
      hostname = "100.119.81.4";
      user = "nix";
      forwardAgent = true;
      setEnv = {
        is_vscode = 1;
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
}
