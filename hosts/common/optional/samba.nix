{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.samba-wsdd.enable = true;
  services.samba-wsdd.workgroup = "WORKGROUP";
  networking.firewall.allowedTCPPorts = [
    5357 # wsdd
  ];
  networking.firewall.allowedUDPPorts = [
    3702 # wsdd
  ];
  services.samba = {
    enable = true;
    enableNmbd = true; # namespace and browsing suport
    enableWinbindd = true; # integrations linux user auth
    openFirewall = true;
    settings.global = {
      workgroup = "WORKGROUP";
      "server string" = "nas";
      "netbios name" = "nas";
      "security type" = "user";
      "hosts allow" = "10.0.7. 10.0.2. 10.2.0. 100.64.0.0/10 127.0.0.1 localhost";
      "hosts deny" = "0.0.0.0/0";
      "guest account" = "nobody";
      "map to guest" = "bad user";
      "min protocol" = "SMB2";
      "ea support" = "yes";
      "browseable" = "yes";
      "smb encrypt" = "auto";
      "load printers" = "no";
      "printcap name" = "/dev/null";
      "bind interfaces only" = "yes";
      "interfaces" = "lo br0 tailscale0";
      "vfs objects" = "catia fruit streams_xattr";
      "fruit:aapl" = "yes";
      "fruit:posix_rename" = "yes";
      "fruit:nfs_aces" = "no";
      "fruit:zero_file_id" = "yes";
      "fruit:metadata" = "stream";
      "fruit:encoding" = "native";
      "spotlight backend" = "tracker";
      "fruit:model" = "MacPro7,1@ECOLOR=226,226,224";
      "fruit:wipe_intentionally_left_blank_rfork" = "yes";
      "fruit:delete_empty_adfiles" = "yes";
      "fruit:veto_appledouble" = "no";
      "use sendfile" = "yes";
      "store dos attributes" = "yes";
    };

    # Don't forget to run `smbpasswd -a <user>` to set the passwords (the user must already exit)
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
      "vfs objects" = "catia fruit streams_xattr";
      # Time Machine specific optimizations
      "strict allocate" = "yes";
      "allocation roundup size" = "1048576";
      # Improve performance for large files
      "read raw" = "yes";
      "write raw" = "yes";
      "strict locking" = "no";
      "oplocks" = "no";
      "level2 oplocks" = "no";
      # Prevent fragmentation
      "min receivefile size" = "16384";
      # Time Machine specific performance tuning
      "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=65536 SO_SNDBUF=65536";
      "aio read size" = "16384";
      "aio write size" = "16384";
      "aio write behind" = "true";
      # Reduce metadata overhead for Time Machine
      "map archive" = "no";
      "map hidden" = "no";
      "map readonly" = "no";
      "map system" = "no";
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
      # "force group" = "nas";
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
}
