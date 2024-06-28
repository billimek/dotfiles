{ config, pkgs, ... }:
{
  systemd.mounts =
    let
      commonMountOptions = {
        type = "nfs";
        mountConfig = {
          Options = "noatime";
        };
      };
    in
    [
      (
        commonMountOptions
        // {
          what = "10.0.7.7:/mnt/tank/media";
          where = "/mnt/media";
        }
      )
    ];

  systemd.automounts =
    let
      commonAutoMountOptions = {
        wantedBy = [ "multi-user.target" ];
        automountConfig = {
          TimeoutIdleSec = "600";
        };
      };
    in
    [ (commonAutoMountOptions // { where = "/mnt/media"; }) ];
}
