{pkgs, ...}: {
  imports = [
    ./atuin.nix
    ./bash.nix
    ./bat.nix
    ./direnv.nix
    ./fish.nix
    ./nvim.nix
    ./gh.nix
    ./git.nix
    ./ssh.nix
    ./starship.nix
    ./tealdeer.nix
    ./tmux.nix
    ./zoxide.nix
  ];
  home.packages = with pkgs; [
    # _1password # password manager CLI - installing this break op CLI on macbooks
    # age # encryption tool
    bottom # better top "WRITTEN IN RUST"
    # curl # get things from URLs
    dig # DNS lookups
    du-dust # better 'du' "WRITTEN IN RUST"
    duf # better 'df' "WRITTEN IN RUST"
    envsubst # sub env vars
    exa # Better ls "WRITTEN IN RUST"
    fd # better find "WRITTEN IN RUST""
    file # inspect file types
    fzf # fuzzy matcher
    git-crypt # encrypt files in git
    htop # system monitor
    hyperfine # benchmarking tool "WRITTEN IN RUST"
    jq # JSON pretty printer and manipulator
    jwt-cli # JWT tool
    neofetch # show system info
    ouch # better unzip "WRITTEN IN RUST"
    procs # better ps "WRITTEN IN RUST"
    ripgrep # Better grep "WRITTEN IN RUST"
    sd # better sed "WRITTEN IN RUST"
    shellcheck # shell linter
    tokei # better cloc "WRITTEN IN RUST"
    unixtools.watch # watch files and run commands
    unzip # unzip files
    wget # get things from URLs
  ];
}
