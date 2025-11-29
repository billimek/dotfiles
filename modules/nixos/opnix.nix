# OpNix secret management configuration
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.opnix;
in
{
  options.modules.opnix = {
    enable = lib.mkEnableOption "opnix secret management";
  };

  config = lib.mkIf cfg.enable {
    services.onepassword-secrets = {
      enable = true;
      tokenFile = "/etc/opnix-token";
      secrets = {
        garageRpcSecret = {
          reference = "op://nix/garage/rpc_secret";
          owner = "garage";
          group = "garage";
          mode = "0640";
        };
        garageS3AccessKey = {
          reference = "op://nix/garage/access-key";
          owner = "nix";
          group = "users";
          mode = "0600";
        };
        garageS3SecretKey = {
          reference = "op://nix/garage/secret-key";
          owner = "nix";
          group = "users";
          mode = "0600";
        };
        b2AccountId = {
          reference = "op://nix/backblaze-b2/account-id";
          owner = "nix";
          group = "users";
          mode = "0600";
        };
        b2ApplicationKey = {
          reference = "op://nix/backblaze-b2/application-key";
          owner = "nix";
          group = "users";
          mode = "0600";
        };
      };
    };
  };
}
