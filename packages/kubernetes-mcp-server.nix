{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:

let
  version = "0.1.3";
  plat =
    {
      "x86_64-linux" = {
        os = "linux";
        arch = "amd64";
        sha256 = "sha256-Nj5Dp9hlrS1If4ioJ7fTfN1bVrTKb9hq/80OIxpBBKY=";
      };
      "aarch64-linux" = {
        os = "linux";
        arch = "arm64";
        sha256 = "sha256-Ji0/PXgAuIV0tr4wwctGY/gUgfoSvUHgLBDUOmYGnT4=";
      };
      "x86_64-darwin" = {
        os = "darwin";
        arch = "amd64";
        sha256 = "sha256-LlLJoc2ezjkrrIp1VYBjIc3A3aDFiufjopp7ZNkuhxw=";
      };
      "aarch64-darwin" = {
        os = "darwin";
        arch = "arm64";
        sha256 = "sha256-2ifFSwvb9LisR9u3yjzwaaNtZGheA05KvPF/1wFeR7Q=";
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
