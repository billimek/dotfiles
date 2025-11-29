# Locale and timezone settings
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.locale;
in
{
  options.modules.locale = {
    enable = lib.mkEnableOption "locale settings" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    i18n = {
      defaultLocale = lib.mkDefault "en_US.UTF-8";
    };
    time.timeZone = lib.mkDefault "America/New_York";
  };
}
