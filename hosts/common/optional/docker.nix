{
  virtualisation.docker = {
    enable = true;
  };

  # Don't wait for network-online.target - just need basic network.target
  systemd.services.docker.after = [ "network.target" ];
  systemd.services.docker.wants = [ "network.target" ];
}
