{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:

let
  version = "0.1.1";
  plat =
    {
      "x86_64-linux" = {
        os = "linux";
        arch = "amd64";
        sha256 = "sha256-pAzKh+AJtotWRE2OeJ9PEBcxZCuC+vi4TzguuTbpi5U=";
      };
      "aarch64-linux" = {
        os = "linux";
        arch = "arm64";
        sha256 = "sha256-xiYgqu0PaDTp6rkS4EcqREgrgjwSsDbiW2bYcDzfVpU=";
      };
      "x86_64-darwin" = {
        os = "darwin";
        arch = "amd64";
        sha256 = "sha256-xcYuduswAY0FSJPGV2LU+npmDgU/8zx2SK8B2zKq0Qs=";
      };
      "aarch64-darwin" = {
        os = "darwin";
        arch = "arm64";
        sha256 = "sha256-FlD5BGcR67JJycqWKGbe56sQ8Alexvi/4JOE76qSLjA=";
      };
    }
    .${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "kubernetes-mcp-server";
  inherit version;

  src = fetchurl {
    url = "https://github.com/manusa/kubernetes-mcp-server/releases/download/v${version}/kubernetes-mcp-server-${plat.os}-${plat.arch}";
    sha256 = plat.sha256;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    install -Dm755 "$src" "$out/bin/kubernetes-mcp-server"
  '';

  meta = {
    description = "MCP server for Kubernetes cluster interaction";
    homepage = "https://github.com/manusa/kubernetes-mcp-server";
    mainProgram = "kubernetes-mcp-server";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
