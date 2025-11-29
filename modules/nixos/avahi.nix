# Avahi mDNS/DNS-SD service discovery
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.avahi;
in
{
  options.modules.avahi = {
    enable = lib.mkEnableOption "avahi service discovery";
    interface = lib.mkOption {
      type = lib.types.str;
      default = "br0";
      description = "Network interface for avahi";
    };
  };

  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      allowInterfaces = [ cfg.interface ];
      reflector = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
      extraServiceFiles = {
        smb = ''
          <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
            <name replace-wildcards="yes">%h</name>
            <service>
              <type>_smb._tcp</type>
              <port>445</port>
            </service>
          </service-group>
        '';
      };
    };
  };
}
