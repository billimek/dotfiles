{ outputs, lib, ... }:
{
  programs.ssh = {
    enable = true;
  };

  # place ~/.ssh/rc file
  home.file.".ssh/rc".text = ''
    if test "$SSH_AUTH_SOCK"; then
      ln -sf $SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock
    fi
  '';
}
