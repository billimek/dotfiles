# Samba file sharing server
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.samba;
in
{
  options.modules.samba = {
    enable = lib.mkEnableOption "samba file sharing";
  };

  config = lib.mkIf cfg.enable {
    services.samba-wsdd.enable = true;
    services.samba-wsdd.workgroup = "WORKGROUP";

    networking.firewall.allowedTCPPorts = [ 5357 ];
    networking.firewall.allowedUDPPorts = [ 3702 ];

    services.samba = {
      enable = true;
      nmbd.enable = true;
      winbindd.enable = true;
      openFirewall = true;
      settings.global = {
        workgroup = "WORKGROUP";
        "server string" = "nas";
        "netbios name" = "nas";
        "hosts allow" = "10.0.7. 10.0.2. 10.2.0. 100.64.0.0/10 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
        "min protocol" = "SMB3";
        "server min protocol" = "SMB3";
        "server max protocol" = "SMB3";
        "ea support" = "yes";
        "browseable" = "yes";
        "smb encrypt" = "auto";
        "load printers" = "no";
        "printcap name" = "/dev/null";
        "bind interfaces only" = "yes";
        "interfaces" = "lo br0 tailscale0";
        "vfs objects" = "catia fruit streams_xattr";
        "fruit:aapl" = "yes";
        "fruit:posix" = "yes";
        "fruit:posix_rename" = "yes";
        "fruit:nfs_aces" = "no";
        "fruit:zero_file_id" = "yes";
        "fruit:metadata" = "stream";
        "fruit:resource" = "stream";
        "fruit:encoding" = "native";
        "spotlight backend" = "tracker";
        "fruit:model" = "MacPro7,1@ECOLOR=226,226,224";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        "fruit:delete_empty_xattr" = "yes";
        "fruit:veto_appledouble" = "no";
        "use sendfile" = "yes";
        "store dos attributes" = "yes";
        "read raw" = "yes";
        "write raw" = "yes";
        "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=65536 SO_SNDBUF=65536";
      };

      settings.timemachine = {
        path = "/mnt/tank/backups/timemachine";
        comment = "Time Machine";
        browseable = "yes";
        public = "no";
        writeable = "yes";
        "force user" = "root";
        "force group" = "root";
        "fruit:aapl" = "yes";
        "fruit:time machine" = "yes";
        "fruit:time machine max size" = "6144G";
      };

      settings.Tesla = {
        path = "/mnt/tank/media/Videos/Tesla";
        browseable = "yes";
        "force user" = "nas";
        "force group" = "nas";
        "guest ok" = "no";
        public = "no";
        "read only" = "no";
        writeable = "yes";
        "create mask" = "0664";
        "directory mask" = "0775";
        "veto files" = "/._*/.DS_Store/";
        "delete veto files" = "yes";
        "spotlight" = "yes";
      };

      settings.media = {
        path = "/mnt/tank/media";
        browseable = "yes";
        "force user" = "nas";
        "guest ok" = "no";
        public = "no";
        "read only" = "no";
        writeable = "yes";
        "create mask" = "0664";
        "directory mask" = "0775";
        "veto files" = "/._*/.DS_Store/";
        "delete veto files" = "yes";
        "spotlight" = "yes";
      };

      settings.Photographs = {
        path = "/mnt/tank/media/photos";
        browseable = "yes";
        "force user" = "nas";
        "force group" = "nas";
        "guest ok" = "no";
        public = "no";
        "read only" = "no";
        writeable = "yes";
        "create mask" = "0664";
        "directory mask" = "0775";
        "veto files" = "/._*/.DS_Store/";
        "delete veto files" = "yes";
        "spotlight" = "yes";
      };

      settings.backups = {
        path = "/mnt/tank/backups";
        browseable = "yes";
        "force user" = "root";
        "force group" = "root";
        "guest ok" = "no";
        public = "no";
        "read only" = "no";
        writeable = "yes";
        "veto files" = "/._*/.DS_Store/";
        "delete veto files" = "yes";
      };
    };
  };
}
