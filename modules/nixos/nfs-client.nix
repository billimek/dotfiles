# NFS client support
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.nfs-client;
in
{
  options.modules.nfs-client = {
    enable = lib.mkEnableOption "NFS client support" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.nfs-utils ];
    boot.supportedFilesystems = [ "nfs" ];
    services.rpcbind.enable = true;
  };
}
