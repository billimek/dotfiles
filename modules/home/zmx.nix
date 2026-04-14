# zmx session persistence
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.modules.zmx;
in
{
  options.modules.zmx = {
    enable = lib.mkEnableOption "zmx session persistence";
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    home.packages = [ inputs.zmx.packages.${pkgs.system}.default ];

    programs.fish.interactiveShellInit = lib.mkAfter ''
      if type -q zmx
        zmx completions fish | source
      end
    '';
  };
}
