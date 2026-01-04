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
        garageAdminToken = {
          reference = "op://nix/garage/admin_token";
          owner = "garage";
          group = "garage";
          mode = "0640";
        };
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
        nutUpsmonPassword = {
          reference = "op://nix/nut-passwords/upsmon";
          owner = "nutmon";
          group = "nutmon";
          mode = "0640";
        };
        nutMonitorPassword = {
          reference = "op://nix/nut-passwords/monitor";
          owner = "root";
          group = "root";
          mode = "0640";
        };
        discordWebhookUrl = {
          reference = "op://nix/discord/ups-webhook-url";
          owner = "root";
          group = "root";
          mode = "0640";
        };
      };
    };
  };
}
