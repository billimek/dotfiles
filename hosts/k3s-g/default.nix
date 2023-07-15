{
  imports = [
    ./hardware-configuration.nix

    ../common/nixos
    ../common/nixos/users/nix
    ../common/optional/fish.nix
    # ../common/optional/k3s-agent.nix
  ];

  time.timeZone = lib.mkDefault "UTC";

  environment.systemPackages = [
    pkgs.nfs-utils
  ];

  networking = {
    hostName = "k3s-g";
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  };
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";

}
