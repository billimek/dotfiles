let
  agenix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBw5lKuNQ045EFe9AOotxP0OVJ2lXLoyfNe++SQypTWw";
  users = [agenix];

  cloud = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHLDJjELqgRkGx5CoGQaTNir+Zq4sQ9DiueC6jEe3aXO";
  home = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxH/Rf9bkS5qRp9e6BMxbnmrPUvRZ5xNBfpheFl8nAO";
  honeypot = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOnDUYzPX3e44rayelLlFbOM5RJ8YpAskyGphRNctExK";
  systems = [cloud home honeypot];
in {
  "secret.age".publicKeys = users ++ systems;
}
