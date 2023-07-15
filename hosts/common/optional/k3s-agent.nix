{
  # This is required so that pod can reach the API server (running on port 6443 by default)
  networking.firewall.allowedTCPPorts = [ 6443 ];
  services.k3s = {
    enable = true;
    role = "agent";
    serverAddr = lib.mkDefault "https://k3s-0:6443";
    # tokenFile = lib.mkDefault <TBD>;
    extraFlags = [
      "--node-label \"k3s-upgrade=enabled\"" # Optionally add additional args to k3s
    ];
  };

  environment.systemPackages = [ pkgs.k3s ];
}
