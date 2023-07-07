{ inputs, lib, pkgs, config, ... }:
{
  imports = [
    ./common/global
    ./common/features/dev
    ./common/features/kubernetes
    ./common/features/cli/1password.nix
  ];

  home = {
    username = lib.mkDefault "jeff";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.05";
    sessionPath = [ "$HOME/.local/bin" ];
    packages = with pkgs; [
      _1password
      nfs-utils
      socat
    ];
  };

  programs.git = {
    userName = "billimek";
    userEmail = "jeff@billimek.com";
    extraConfig = {
      user = {
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhZTlonLeCLJpBtuSQcqofKoUbr2ajG3JXxZ7Gjdgkh";
      };
    };
  };

  programs.bash = with lib; {
    enable = true;
    # force execution of fish shell when spawning bash
    profileExtra = ''
      exec ${config.home.profileDirectory}/bin/fish
    '';
  };

  programs.fish = {
    shellAbbrs = rec {
      # override with machine-specific values
      rehome = lib.mkForce "home-manager switch --flake $HOME/src/nix-config/.#jeff@honeypot";
    };
    functions = {
      _1password_agent_wsl = {
        description = "Creates socat npiperelay with windows-based 1Password";
        body = ''
          set -gx SSH_AUTH_SOCK $HOME/.1password/agent.sock
          # need `ps -ww` to get non-truncated command for matching
          # use square brackets to generate a regex match for the process we want but that doesn't match the grep command running it!
          set ALREADY_RUNNING (
                  ps -auxww | grep -q "[n]piperelay.exe -ei -s //./pipe/openssh-ssh-agent"
            echo $status)
          if test $ALREADY_RUNNING != "0"
                  if test -S $SSH_AUTH_SOCK
                          # not expecting the socket to exist as the forwarding command isn't running (http://www.tldp.org/LDP/abs/html/fto.html)
                          echo "removing previous socket..."
                          rm $SSH_AUTH_SOCK
            end
                  echo "Starting SSH-Agent relay..."
                  # setsid to force new session to keep running
                  # set socat to listen on $SSH_AUTH_SOCK and forward to npiperelay which then forwards to openssh-ssh-agent on windows
            set agent (setsid socat "UNIX-LISTEN:$SSH_AUTH_SOCK,fork" "EXEC:/mnt/c/npiperelay/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) &>/dev/null
            disown
          end
        '';
      };
    };

    shellInit = ''
      set -gx SSH_AUTH_SOCK '/home/jeff/.1password/agent.sock'
    '';
    interactiveShellInit =
      # run 1password agent bride
      ''
      # .config/.agent-bridge.sh
      _1password_agent_wsl
      '';
  };

  # WSL doesn't have systemd, so we need to null-this out here.
  systemd.user.startServices = lib.mkForce false;

}
