{ config, pkgs, ... }:
{
  environment.systemPackages = [ pkgs.nfs-utils ];

  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true; # needed for NFS
}
