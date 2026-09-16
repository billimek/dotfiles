{ ... }:
{
  flake.homeManagerModules.forgejo-cli =
    # Forgejo CLI
    {
      config,
      lib,
      pkgs,
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
        # fjo (github.com/perfectra1n/fjo, formerly fcli) installed alongside
        # forgejo-cli for evaluation -- unpackaged upstream, pinned via the
        # `additions` overlay.
        home.packages = (with pkgs-unstable; [ forgejo-cli ]) ++ (with pkgs; [ fjo ]);
      };
    };
}
