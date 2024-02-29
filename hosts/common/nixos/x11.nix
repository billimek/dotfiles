{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    pkgs.xorg.xauth
  ];
}
