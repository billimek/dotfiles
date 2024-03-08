{
  config,
  pkgs,
  ...
}: {
  services.sanoid = {
    enable = true;
    extraArgs = ["--verbose"];
    templates = {
      "timemachine" = {
        "hourly" = 0;
        "daily" = 14;
        "monthly" = 3;
        "yearly" = 0;
        "autosnap" = true;
        "autoprune" = true;
      };
      "vms" = {
        "hourly" = 6;
        "daily" = 14;
        "monthly" = 3;
        "yearly" = 0;
        "autosnap" = true;
        "autoprune" = true;
      };
    };
  };
}
