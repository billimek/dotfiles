{
  config,
  pkgs,
  ...
}: {
  boot.supportedFilesystems = [ "zfs" ]; # Enable ZFS support
  boot.zfs.requestEncryptionCredentials = true; # If you're using ZFS encryption, set this to true to prompt for encryption passwords at boot
  boot.zfs.extraPools = ["tank-test" "ssdtank-test"];

  services.zfs.autoScrub = {
    enable = true; # Enable automatic ZFS scrubbing
    interval = "monthly"; # Set the scrubbing interval to 1 month
  };

  environment.systemPackages = with pkgs; [ zfs ]; # Install the ZFS package
}
