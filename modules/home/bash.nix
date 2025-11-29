# Bash shell
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.bash;
in
{
  options.modules.bash = {
    enable = lib.mkEnableOption "bash" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.bash = {
      enable = true;
    };
  };
}
