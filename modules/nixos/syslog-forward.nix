{ config, lib, ... }:
let
  cfg = config.modules.syslog-forward;
in
{
  options.modules.syslog-forward = {
    enable = lib.mkEnableOption "Forward journald logs over UDP syslog (RFC5424)";
    target = lib.mkOption {
      type = lib.types.str;
      default = "10.0.6.58";
      description = "Destination host/IP for syslog UDP packets.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 514;
      description = "Destination UDP port.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.syslog-ng = {
      enable = true;
      extraConfig = ''
        source s_journal { systemd-journal(); };
        destination d_remote {
          syslog(
            "${cfg.target}"
            transport("udp")
            port(${toString cfg.port})
          );
        };
        log { source(s_journal); destination(d_remote); };
      '';
    };
  };
}
