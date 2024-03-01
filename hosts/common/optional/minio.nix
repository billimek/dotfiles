{
  config,
  lib,
  pkgs,
  ...
}: let
  secrets = import ../../../secrets.nix;
in {
  environment.systemPackages = with pkgs; [
    minio-client
  ];
  services.minio = {
    enable = true;
    # TODO: rename dataDir to the actualk location when ready
    dataDir = ["/mnt/ssdtank/s3-new"];
    package = pkgs.minio;
    accessKey = secrets.minio.accessKey;
    secretKey = secrets.minio.secretKey;
  };
}
