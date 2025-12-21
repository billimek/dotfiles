# Home Manager configuration for jeff on Jeffs-M3Pro (personal MacBook)
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../default.nix
  ];

  # Enable optional feature modules
  modules = {
    dev.enable = true;
    kubernetes.enable = true;

  };

  home = {
    homeDirectory = "/Users/${config.home.username}";
    packages = with pkgs; [
      terminal-notifier # send notifications to macOS notification center
    ];
  };

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

   programs.fish = {
     shellAbbrs = rec { };
     shellAliases = { };
     shellInit = ''
       # set -gx SSH_AUTH_SOCK '$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock'
       # set -gx FLAKE "$HOME/src/dotfiles"
       set -gx NH_FLAKE "$HOME/src/dotfiles"
       fish_add_path /Users/jeff/.opencode/bin
     '';

    loginShellInit = ''for p in (string split " " $NIX_PROFILES); fish_add_path --prepend --move $p/bin; end'';

    interactiveShellInit =
      # fix brew path (should not be needed but somehow is?)
      ''
        eval (/opt/homebrew/bin/brew shellenv)
      '';
  };
}
