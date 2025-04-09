{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.nfs.server = {
    enable = true;
    statdPort = 4000;
    lockdPort = 4001;
    mountdPort = 4002;
    exports = ''
      "/mnt/tank/media"\
          10.0.2.0/24(sec=sys,rw,anonuid=1001,anongid=1001,all_squash,insecure,no_subtree_check)\
          10.2.0.0/24(sec=sys,rw,anonuid=1001,anongid=1001,all_squash,insecure,no_subtree_check)\
          100.64.0.0/10(sec=sys,rw,anonuid=1001,anongid=1001,all_squash,insecure,no_subtree_check)\
          10.0.7.0/24(sec=sys,rw,anonuid=1001,anongid=1001,all_squash,insecure,no_subtree_check)
      "/mnt/tank/backups"\
              10.0.7.0/24(sec=sys,rw,anonuid=0,anongid=0,all_squash,insecure,no_subtree_check)\
              10.2.0.0/24(sec=sys,rw,anonuid=0,anongid=0,all_squash,insecure,no_subtree_check)
      "/mnt/tank/data"\
              10.0.7.0/24(sec=sys,rw,anonuid=0,anongid=0,all_squash,insecure,no_subtree_check)\
              10.2.0.0/24(sec=sys,rw,anonuid=0,anongid=0,all_squash,insecure,no_subtree_check)
      "/mnt/tank/proxmox"\
              10.0.7.14(sec=sys,rw,anonuid=0,anongid=65534,all_squash,insecure,no_subtree_check)\
              10.0.7.9(sec=sys,rw,anonuid=0,anongid=65534,all_squash,insecure,no_subtree_check)
      "/mnt/tank/data/k8s-nfs"\
              10.0.7.0/24(sec=sys,rw,anonuid=0,anongid=0,all_squash,insecure,no_subtree_check)\
              10.2.0.0/24(sec=sys,rw,anonuid=0,anongid=0,all_squash,insecure,no_subtree_check)
      "/mnt/ssdtank/s3"\
              100.116.152.46(sec=sys,rw,anonuid=0,anongid=0,all_squash,insecure,no_subtree_check)\
              10.2.0.0/24(sec=sys,rw,anonuid=0,anongid=0,all_squash,insecure,no_subtree_check)\
              10.0.7.0/24(sec=sys,rw,anonuid=0,anongid=0,all_squash,insecure,no_subtree_check)
    '';
  };

  networking.firewall.allowedTCPPorts = [
    111
    2049
    4000
    4001
    4002
    20048
  ];
  networking.firewall.allowedUDPPorts = [
    111
    2049
    4000
    4001
    4002
    20048
  ];
}
