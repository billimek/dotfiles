# Sanoid ZFS snapshot management
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.sanoid;
in
{
  options.modules.sanoid = {
    enable = lib.mkEnableOption "sanoid ZFS snapshots";
  };

  config = lib.mkIf cfg.enable {
    services.sanoid = {
      enable = true;
      extraArgs = [ "--verbose" ];
      templates = {
        "backups" = {
          "hourly" = 0;
          "daily" = 0;
          "monthly" = 6;
          "yearly" = 2;
          "autosnap" = true;
          "autoprune" = true;
        };
      };
    };
  };
}
