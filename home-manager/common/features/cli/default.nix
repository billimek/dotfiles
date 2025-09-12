{pkgs, ...}: {
  imports = [
    ./atuin.nix
    ./bash.nix
    ./bat.nix
    ./direnv.nix
    ./fish.nix
    ./ghostty.nix
    ./nvf.nix
    ./gh.nix
    ./git.nix
    ./lsd.nix
    #./opnix.nix
    ./ssh.nix
    ./starship.nix
    ./tealdeer.nix
    ./tmux.nix
    ./zoxide.nix
  ];
  home.packages = with pkgs; [
    # _1password # password manager CLI - installing this break op CLI on macbooks
    # age # encryption tool
    any-nix-shell # supports any shell in nix-shell (https://github.com/haslersn/any-nix-shell)
    bottom # better top "WRITTEN IN RUST"
    btop
    # curl # get things from URLs
    dig # DNS lookups
    dogdns # DNS lookups "WRITTEN IN RUST"
    du-dust # better 'du' "WRITTEN IN RUST"
    duf # better 'df' "WRITTEN IN RUST"
    envsubst # sub env vars
    unstable.eza # replacement for exa "WRITTEN IN RUST"
    unstable.fastfetch # fetch system info
    fd # better find "WRITTEN IN RUST""
    file # inspect file types
    fzf # fuzzy matcher
    git-crypt # encrypt files in git
    htop # system monitor
    hyperfine # benchmarking tool "WRITTEN IN RUST"
    ipcalc # calculate IP ranges
    ipinfo # get IP info
    jq # JSON pretty printer and manipulator
    jwt-cli # JWT tool
    lazygit
    nixd # nix daemon
    nixfmt-rfc-style # nix formatter
    nvd
    ouch # better unzip "WRITTEN IN RUST"
    procs # better ps "WRITTEN IN RUST"
    ripgrep # Better grep "WRITTEN IN RUST"
    sd # better sed "WRITTEN IN RUST"
    shellcheck # shell linter
    unstable.tailscale
    tokei # better cloc "WRITTEN IN RUST"
    unixtools.watch # watch files and run commands
    unzip # unzip files
    wget # get things from URLs
    yq # YAML pretty printer and manipulator
  ];
}
