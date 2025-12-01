# ZFS filesystem support
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.zfs;
in
{
  options.modules.zfs = {
    enable = lib.mkEnableOption "ZFS support";
  };

  config = lib.mkIf cfg.enable {
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.requestEncryptionCredentials = true;

    services.zfs.autoScrub = {
      enable = true;
      interval = "monthly";
    };

    services.zfs.trim.enable = true;

    environment.systemPackages = with pkgs; [
      zfs
      httm
      sanoid
    ];
  };
}
