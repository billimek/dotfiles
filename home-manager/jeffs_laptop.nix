{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: {
  imports = [
    ./common/global
    ./common/features/dev
    ./common/features/kubernetes
  ];

  home = {
    username = lib.mkDefault "jeff";
    homeDirectory = lib.mkDefault "/Users/${config.home.username}";
    stateVersion = lib.mkDefault "23.05";
    sessionPath = ["$HOME/.local/bin"];
  };

  home.packages = with pkgs; [
    terminal-notifier # send notifications to macOS notification center
  ];

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
        extraOptions = {
          IdentityAgent = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
        };
      };
    };
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

  programs.fish = {
    shellAbbrs = rec {
      # override with machine-specific values
      rehome = lib.mkForce "home-manager switch --flake $HOME/src/dotfiles/.#(whoami)@(hostname)";
      rebuild = lib.mkForce "darwin-rebuild switch --flake $HOME/src/dotfiles/.#";
    };
    shellAliases = {
    };
    shellInit = ''
      # set -gx SSH_AUTH_SOCK '$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock'
    '';

    loginShellInit = ''for p in (string split " " $NIX_PROFILES); fish_add_path --prepend --move $p/bin; end'';

    interactiveShellInit =
      # fix brew path (should not be needed but somehow is?)
      ''
        eval (/opt/homebrew/bin/brew shellenv)
      '';
  };
}
