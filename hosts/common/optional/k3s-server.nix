{
  config,
  pkgs,
  lib,
  ...
}:
let
  secrets = import ../../../secrets.nix;
in
{
  # This is required so that pod can reach the API server (running on port 6443 by default)
  networking.firewall.allowedTCPPorts = [ 6443 ];
  services.k3s = {
    enable = true;
    package = pkgs.unstable.k3s_1_30;
    role = "server";
    token = lib.mkDefault secrets.k3s_node_token;
    extraFlags = "--tls-san k3s-0 --disable servicelb --disable traefik --disable local-storage --flannel-backend=host-gw --node-taint \"node-role.kubernetes.io/master=true:NoSchedule\" --node-label \"k3s-upgrade=false\"";
    #extraKubeletConfig = {
    #  imageMaximumGCAge = "168h";
    #};
  };

  environment.systemPackages = [
    pkgs.unstable.k3s_1_30
    pkgs.kubectl
  ];

  programs.nbd.enable = true;

  # create symlink from /run/current-system/sw/bin/test to /usr/bin/test for kured to work
  system.activationScripts.test = ''
    if [ ! -e /usr/bin/test ]; then
      ln -s ${pkgs.coreutils}/bin/test /usr/bin/test
    fi
    if [ ! -e /usr/bin/systemctl ]; then
      ln -s ${pkgs.systemd}/bin/systemctl /usr/bin/systemctl
    fi
  '';
}
