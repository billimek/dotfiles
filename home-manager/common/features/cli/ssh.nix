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
  };

  # place ~/.ssh/rc file
  home.file.".ssh/rc".text = ''
    if test "$SSH_AUTH_SOCK"; then
      ln -sf $SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock
    fi
  '';
}
