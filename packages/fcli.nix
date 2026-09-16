{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage rec {
  pname = "fcli";
  # No tagged release yet (repo created 2026-09-13); pinned to latest main.
  version = "0-unstable-2026-09-15";

  src = fetchFromGitHub {
    owner = "perfectra1n";
    repo = "fcli";
    rev = "12fa9f1dd9d68de344ec51785f11220cec5b179d";
    sha256 = "sha256-7skkJdFj8lUHNM34uTApdiEn/SgukCSwnrElQOprUck=";
  };

  cargoHash = "sha256-PfrW6LZK0r4WWwtH9zBWwoCNtgaragsDoAJzZQ4U14k=";

  cargoBuildFlags = [
    "-p"
    "fcli"
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  doCheck = false;

  meta = {
    description = "CLI for interacting with Forgejo, styled after gh";
    mainProgram = "fcli";
    homepage = "https://github.com/perfectra1n/fcli";
    license = lib.licenses.agpl3Only;
  };
}
