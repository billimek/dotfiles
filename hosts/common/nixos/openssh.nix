{
  outputs,
  lib,
  config,
  ...
}:
let
  inherit (config.networking) hostName;
  hosts = outputs.nixosConfigurations;
in
#   pubKey = host: ../../${host}/ssh_host_ed25519_key.pub;
{
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
}
