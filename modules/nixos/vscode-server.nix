# VSCode Remote Server support
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.vscode-server;
in
{
  options.modules.vscode-server = {
    enable = lib.mkEnableOption "VSCode remote server support";
  };

  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = true;
    services.openssh.extraConfig = ''
      AcceptEnv is_vscode
    '';
  };
}
