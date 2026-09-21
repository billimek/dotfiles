{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  apple-sdk,
}:

rustPlatform.buildRustPackage rec {
  pname = "fjo";
  # No tagged release yet (repo created 2026-09-13); pinned to latest main.
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "perfectra1n";
    repo = "fjo";
    rev = "549b179c8d6c5d340f6b086dd0ae9528791fea49";
    sha256 = "sha256-3vVDSJxOPcetr27pG9L/CUw9BajbU6FrTCNUrijehpw=";
  };

  # Vendored lockfile drives importCargoLock (curl) instead of fetchCargoVendor
  # (python), whose Python 3.13 strict X.509 checks reject the corporate
  # TLS-inspection proxy's leaf certs.
  cargoLock.lockFile = ./fjo-Cargo.lock;

  cargoBuildFlags = [
    "-p"
    "fjo"
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ apple-sdk ];

  doCheck = false;

  meta = {
    description = "CLI for interacting with Forgejo, styled after gh";
    mainProgram = "fjo";
    homepage = "https://github.com/perfectra1n/fjo";
    license = lib.licenses.agpl3Only;
  };
}
