{
  programs.onepassword-secrets = {
    enable = true;
    secrets = [
      # {
      #   # Paths are relative to home directory
      #   path = ".ssh/id_rsa";
      #   reference = "op://Personal/ssh-key/private-key";
      # }
      {
        path = ".config/secret-app/token";
        reference = "op://nix/test/test-cred";
      }
    ];
  };
}
