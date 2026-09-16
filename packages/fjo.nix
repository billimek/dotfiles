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
  version = "0-unstable-2026-09-16";

  src = fetchFromGitHub {
    owner = "perfectra1n";
    repo = "fjo";
    rev = "549b179c8d6c5d340f6b086dd0ae9528791fea49";
    sha256 = "sha256-3vVDSJxOPcetr27pG9L/CUw9BajbU6FrTCNUrijehpw=";
  };

  cargoHash = "sha256-KTs7v2t1pdw8Hka5Irwtz7OlR6Wnj9GpvB7K7v62tBc=";

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
