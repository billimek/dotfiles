{
  pkgs,
  lib,
  buildGoModule,
  ...
}:

(buildGoModule.override { go = pkgs.unstable.go_1_27; }) rec {
  # go.mod requires go >= 1.27.0; the default go attribute is still 1.26.
  pname = "topf";
  version = "0.6.1";

  src = pkgs.fetchFromGitHub {
    owner = "postfinance";
    repo = "topf";
    rev = "v${version}";
    sha256 = "sha256-avrcOu+6hGqr/wtxQl/ysf7E76b+XtGf2lxDrJqnzJY=";
  };

  vendorHash = "sha256-yxQCn9S0U5AjxJUmTt/eKopnZ1W+J6Zj8QaTS7W1X0w=";

  doCheck = false;

  meta = {
    description = "Template files with values from Vault, files or environment variables";
    mainProgram = "topf";
    homepage = "https://github.com/postfinance/topf";
    changelog = "https://github.com/postfinance/topf/releases/tag/v${version}";
  };
}
