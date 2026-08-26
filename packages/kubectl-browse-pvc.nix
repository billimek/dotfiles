{
  pkgs,
  lib,
  buildGoModule,
  ...
}:

buildGoModule rec {
  pname = "kubectl-browse-pvc";
  version = "1.4.4";

  src = pkgs.fetchFromGitHub {
    owner = "clbx";
    repo = "kubectl-browse-pvc";
    rev = "v${version}";
    sha256 = "sha256-xWNyZoYbyjnx61qpud91K2BpS3+pJ77ay1b3vF43aW4=";
  };

  vendorHash = "sha256-cL/5nNOpo8MM1/0D+vomB60KUeH6/YP5j4DJepUx9iE=";

  doCheck = false;

  postInstall = ''
    mv $out/bin/browse-pvc $out/bin/kubectl-browse_pvc
  '';

  meta = {
    description = "Kubernetes CLI plugin for browsing PVCs on the command line";
    mainProgram = "kubectl-browse-pvc";
    homepage = "https://github.com/clbx/kubectl-browse-pvc";
    changelog = "https://github.com/clbx/kubectl-browse-pvc/releases/tag/v${version}";
  };
}
