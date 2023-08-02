{
  programs.nix-ld.enable = true;
  services.openssh.extraConfig = ''
    AcceptEnv is_vscode
  '';
}
