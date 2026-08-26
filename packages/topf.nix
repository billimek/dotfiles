{
  pkgs,
  lib,
  buildGoModule,
  ...
}:

buildGoModule rec {
  pname = "topf";
  version = "0.5.0";

  src = pkgs.fetchFromGitHub {
    owner = "postfinance";
    repo = "topf";
    rev = "v${version}";
    sha256 = "sha256-q9Gr1UuFOxptui6ZOhE0qTMXXVAkLjkAX0n9rzlpaOU=";
  };

  vendorHash = "sha256-TyrlEJjh3SwBaGowM+f096GM2WGfDcxW+RWqspAB7rU=";

  doCheck = false;

  meta = {
    description = "Template files with values from Vault, files or environment variables";
    mainProgram = "topf";
    homepage = "https://github.com/postfinance/topf";
    changelog = "https://github.com/postfinance/topf/releases/tag/v${version}";
  };
}
