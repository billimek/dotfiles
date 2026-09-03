{
  pkgs,
  lib,
  buildGoModule,
  ...
}:

(buildGoModule.override { go = pkgs.unstable.go; }) rec {
  # go.mod requires go >= 1.26.7; pinned nixpkgs only has 1.26.6.
  pname = "topf";
  version = "0.6.0";

  src = pkgs.fetchFromGitHub {
    owner = "postfinance";
    repo = "topf";
    rev = "v${version}";
    sha256 = "sha256-NRKRROq6uxLlAHCtpT+s+eBVjFgf8qjjwlYGhdNApUs=";
  };

  vendorHash = "sha256-9xYy1Ep7bZ0nW63fmrxiqfOrHWt7Kcn+zGhcjBpdvYY=";

  doCheck = false;

  meta = {
    description = "Template files with values from Vault, files or environment variables";
    mainProgram = "topf";
    homepage = "https://github.com/postfinance/topf";
    changelog = "https://github.com/postfinance/topf/releases/tag/v${version}";
  };
}
