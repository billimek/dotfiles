{ ... }:
{
  flake.homeManagerModules.forgejo-cli =
    # Forgejo CLI
    {
      config,
      lib,
      pkgs-unstable,
      ...
    }:
    let
      cfg = config.modules.forgejo-cli;
    in
    {
      options.modules.forgejo-cli = {
        enable = lib.mkEnableOption "Forgejo CLI" // {
          default = true;
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = with pkgs-unstable; [ forgejo-cli ];
      };
    };
}
