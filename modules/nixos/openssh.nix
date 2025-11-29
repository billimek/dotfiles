# OpenSSH server configuration
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.openssh;
in
{
  options.modules.openssh = {
    enable = lib.mkEnableOption "openssh server" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        # Harden
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        # Automatically remove stale sockets
        StreamLocalBindUnlink = "yes";
        # Allow forwarding ports to everywhere
        GatewayPorts = "clientspecified";
        # Allow X11 forwarding
        X11Forwarding = true;
      };
    };

    # Passwordless sudo when SSH'ing with keys
    security.pam.sshAgentAuth.enable = true;
  };
}
