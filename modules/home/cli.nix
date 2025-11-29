# CLI tools bundle - common command-line utilities
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.cli;
in
{
  options.modules.cli = {
    enable = lib.mkEnableOption "CLI tools bundle" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable comma and nix-index with automatic database updates
    programs.nix-index-database.comma.enable = true;

    home.packages = with pkgs; [
      any-nix-shell
      bottom
      btop
      dig
      dogdns
      du-dust
      duf
      envsubst
      unstable.eza
      unstable.fastfetch
      fd
      file
      fzf
      git-crypt
      htop
      hyperfine
      ipcalc
      ipinfo
      jq
      jwt-cli
      lazygit
      nixd
      nixfmt-rfc-style
      nvd
      ouch
      procs
      ripgrep
      sd
      shellcheck
      tokei
      unixtools.watch
      unzip
      wget
      yq
    ];
  };
}
