{ pkgs, lib, config, ... }: {
  programs.atuin = {
    enable = true;
    package = pkgs.unstable.atuin;

    flags = [ "--disable-up-arrow" ];

    settings = {
      auto_sync = true;
      sync_frequency = "1h";
      search_mode = "fuzzy";
      sync.records = true;
    };
  };
}
