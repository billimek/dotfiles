{
  config,
  lib,
  pkgs,
  ...
}:
let
  secrets = import ../../../secrets.nix;
in
{
  environment.systemPackages = with pkgs; [ minio-client ];
  services.minio = {
    enable = false;
    dataDir = [ "/mnt/ssdtank/s3" ];
    package = pkgs.minio;
    # TODO: switch these to rootCredentialsFile
    accessKey = secrets.minio.accessKey;
    secretKey = secrets.minio.secretKey;
  };
}
