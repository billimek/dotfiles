{
  pkgs,
  lib,
  buildGoModule,
  ...
}:

buildGoModule rec {
  pname = "kubectl-browse-pvc";
  version = "1.3.0";
  
  src = pkgs.fetchFromGitHub {
    owner = "clbx";
    repo = "kubectl-browse-pvc";
    rev = "v${version}";
    sha256 = "sha256-8O36JLNfrh+/9JqJjeeSEO88uYkoo6OXCraK385tGvM=";
  };

  vendorHash = "sha256-WwEFtiWP9rQnOjMNnY8nFBKvw0Gp29wcKrLrUqOr7DQ=";

  doCheck = false;
  
  # Point to the correct source directory containing go.mod
  sourceRoot = "source/src";

  postInstall = ''
    mv $out/bin/kubectl-browse-pvc $out/bin/kubectl-browse_pvc
  '';

  meta = {
    description = "Kubernetes CLI plugin for browsing PVCs on the command line";
    mainProgram = "kubectl-browse-pvc";
    homepage = "https://github.com/clbx/kubectl-browse-pvc";
    changelog = "https://github.com/clbx/kubectl-browse-pvc/releases/tag/v${version}";
  };
}