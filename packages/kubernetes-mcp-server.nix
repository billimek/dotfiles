{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:

let
  version = "0.1.2";
  plat =
    {
      "x86_64-linux" = {
        os = "linux";
        arch = "amd64";
        sha256 = "sha256-T1mfGsruhLwR2+6Q62U4oDQQZR3ifsGaSbWpfkowyrY=";
      };
      "aarch64-linux" = {
        os = "linux";
        arch = "arm64";
        sha256 = "sha256-H6W/Qbn1mw+myAEuBjyYo5AL9e2hQoEKdIcYhez87Y8=";
      };
      "x86_64-darwin" = {
        os = "darwin";
        arch = "amd64";
        sha256 = "sha256-kdS1NdKhhVs8dM4Kop6jo6QZGrF630qM+5gXpjP68v4=";
      };
      "aarch64-darwin" = {
        os = "darwin";
        arch = "arm64";
        sha256 = "sha256-5FDILcLW3sWkp/uoddb7hBAOKmhjVmMESylcGZa7uCs=";
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
