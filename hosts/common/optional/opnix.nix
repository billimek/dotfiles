{
  # Centralized OpNix secret management for all services
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
    secrets = {
      # Garage service secrets
      garageRpcSecret = {
        reference = "op://nix/garage/rpc_secret";
        owner = "garage";
        group = "garage";
        mode = "0640";
      };
      # Rclone secrets for dynamic config generation
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
}