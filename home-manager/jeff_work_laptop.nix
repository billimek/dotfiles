{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}:
let
  secrets = import ../secrets.nix;
in
{
  imports = [
    ./common/global
    ./common/features/dev
    ./common/features/kubernetes
  ];

  home = {
    username = lib.mkDefault secrets.work_username;
    homeDirectory = lib.mkDefault "/Users/${config.home.username}";
    stateVersion = lib.mkDefault "23.11";
  };

  home.packages = with pkgs; [
    act
    cloudfoundry-cli
    crane
    unstable.fly
    jwt-cli
    python3
    rancher
    terminal-notifier # send notifications to macOS notification center
    terraform
    yq
  ];

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
        extraOptions = {
          IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
        };
      };
    };
  };

  # place ~/.ssh/id_personal.pub file
  home.file.".ssh/id_personal.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhZTlonLeCLJpBtuSQcqofKoUbr2ajG3JXxZ7Gjdgkh
  '';
  # place ~/.ssh/id_ghec.pub file
  home.file.".ssh/id_ghec.pub".text = secrets.work_git_pubkey;

  programs.git = {
    userName = "Jeff Billimek";
    userEmail = secrets.work_email;
    extraConfig = {
      user = {
        signingKey = secrets.work_git_pubkey;
      };
      gpg = {
        program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        format = "ssh";
      };
      core.sshCommand = "ssh -i ~/.ssh/id_ghec.pub -o IdentitiesOnly=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
    };
    includes = [
      {
        condition = "gitdir:~/src.github/";
        contents = {
          user = {
            name = "Jeff Billimek";
            email = "jeff@billimek.com";
            signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhZTlonLeCLJpBtuSQcqofKoUbr2ajG3JXxZ7Gjdgkh";
          };
          core = {
            sshCommand = "ssh -i ~/.ssh/id_personal.pub -o IdentitiesOnly=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
          };
        };
      }
    ];
  };

  programs.fish = {
    shellAbbrs = rec {
      tf = "terraform";
      sshblock = secrets.work_sshblock;
      rebuild = lib.mkForce "nh os switch --pull -H work-laptop";
      rehome = lib.mkForce "nh home switch --pull -c 'jeff@work-laptop'";
    };
    shellAliases = {
      code = "/Applications/Visual\\ Studio\\ Code.app/Contents/Resources/app/bin/code";
      # alias git to the default macOS version so that keychain certs are properly used for https operations
      git = "/usr/bin/git";
    };
    shellInit = ''
      # set -gx SSH_AUTH_SOCK '$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock'
      # set -gx NIX_SSL_CERT_FILE ${secrets.work_certpath}
      set -gx FLAKE "$HOME/src.github/dotfiles"
    '';

    loginShellInit = ''for p in (string split " " $NIX_PROFILES); fish_add_path --prepend --move $p/bin; end'';

    interactiveShellInit =
      # fix brew path (should not be needed but somehow is?)
      ''
        eval (/opt/homebrew/bin/brew shellenv)
      ''
      +
        # handle gcloud CLI
        ''
          bass source ~/google-cloud-sdk/path.bash.inc
          bass source ~/google-cloud-sdk/completion.bash.inc
        ''
      +
        # add custom localized paths
        ''
          fish_add_path $HOME/.rd/bin
        '';
  };
}
