# NFS mount configurations for client machines
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nfs-mounts;
in
{
  options.modules.nfs-mounts = {
    media.enable = lib.mkEnableOption "mount media NFS share";
    ssdtank.enable = lib.mkEnableOption "mount ssdtank NFS share";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.media.enable {
      systemd.mounts = [
        {
          type = "nfs";
          what = "10.0.7.7:/mnt/tank/media";
          where = "/mnt/media";
          mountConfig = {
            Options = "noatime";
          };
        }
      ];

      systemd.automounts = [
        {
          where = "/mnt/media";
          wantedBy = [ "multi-user.target" ];
          automountConfig = {
            TimeoutIdleSec = "600";
          };
        }
      ];
    })

    (lib.mkIf cfg.backups.enable {
      systemd.mounts = [
        {
          type = "nfs";
          what = "10.0.7.7:/mnt/tank/backups";
          where = "/mnt/backups";
          mountConfig = {
            Options = "noatime";
          };
        }
      ];

      systemd.automounts = [
        {
          where = "/mnt/backups";
          wantedBy = [ "multi-user.target" ];
          automountConfig = {
            TimeoutIdleSec = "600";
          };
        }
      ];
    })

    (lib.mkIf cfg.ssdtank.enable {
      systemd.mounts = [
        {
          type = "nfs";
          what = "10.0.7.7:/mnt/ssdtank/s3";
          where = "/mnt/ssdtank";
          mountConfig = {
            Options = "noatime";
          };
        }
      ];

      systemd.automounts = [
        {
          where = "/mnt/ssdtank";
          wantedBy = [ "multi-user.target" ];
          automountConfig = {
            TimeoutIdleSec = "600";
          };
        }
      ];
    })
  ];
}
