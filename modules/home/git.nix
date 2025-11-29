# Git configuration
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.git;
in
{
  options.modules.git = {
    enable = lib.mkEnableOption "git configuration" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      package = pkgs.git;
      aliases = {
        a = "add";
        snapshot = ''!git stash save "snapshot: $(date)" && git stash apply "stash@{0}"'';
        snapshots = "!git stash list --grep snapshot";
        b = "branch -v";
        c = "commit --signoff -m";
        ca = "commit --signoff -am";
        ci = "commit --signoff";
        commit = "commit --signoff";
        co = "checkout";
        d = "diff";
        l = "log --graph --date=short";
        nb = "checkout -b";
        r = "remote -v";
        uncommit = "reset --soft HEAD^";
        s = "status";
        t = "tag -n";
      };
      signing = {
        format = "ssh";
        signByDefault = true;
      };
      extraConfig = {
        apply.whitespace = "nowarm";
        branch.autosetupmerge = true;
        color.ui = true;
        core = {
          autocrlf = false;
          editor = "nvim";
          pager = "less -x2";
        };
        fetch.prune = true;
        format.pretty = "format:%C(blue)%ad%Creset %C(yellow)%h%C(green)%d%Creset %C(blue)%s %C(magenta) [%an]%Creset";
        merge = {
          summary = true;
          verbosity = "1";
        };
        push.default = "upstream";
        pull.ff = "only";
      };
      ignores = [
        ".direnv"
        "result"
      ];
    };
  };
}
