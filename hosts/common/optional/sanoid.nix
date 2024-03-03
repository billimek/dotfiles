{
  config,
  pkgs,
  ...
}: {
  services.sanoid = {
    enable = true;
    extraArgs = [ "--verbose" ];
    templates = {
      "timemachine" = {
        "daily" = 14;
        "monthly" = 3;
        "autosnap" = true;
        "autoprune" = true;
      };
      "vms" = {
        "daily" = 14;
        "autosnap" = true;
        "autoprune" = true;
      };
    };
  };
}
