{
  pkgs,
  lib,
  buildGoModule,
  ...
}:

(buildGoModule.override { go = pkgs.unstable.go_1_27; }) rec {
  # go.mod requires go >= 1.27.0; the default go attribute is still 1.26.
  pname = "topf";
  version = "0.6.2";

  src = pkgs.fetchFromGitHub {
    owner = "postfinance";
    repo = "topf";
    rev = "v${version}";
    sha256 = "sha256-frUyZtpA0iyFwHxlN5SqZ0WFfU4sMalmdkHtulg+B3I=";
  };

  vendorHash = "sha256-VLZLPM1/a1Lf5ggk4pwB/AL+Drrdfmm3f9DYjvpBKcA=";

  doCheck = false;

  meta = {
    description = "Template files with values from Vault, files or environment variables";
    mainProgram = "topf";
    homepage = "https://github.com/postfinance/topf";
    changelog = "https://github.com/postfinance/topf/releases/tag/v${version}";
  };
}
