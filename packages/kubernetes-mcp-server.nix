{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:

let
  version = "0.0.69";
  plat =
    {
      "x86_64-linux" = {
        os = "linux";
        arch = "amd64";
        sha256 = "sha256-L0igphArKkpuAvIQhI//Vr9iEwKnMJVITZuLM/yNieo=";
      };
      "aarch64-linux" = {
        os = "linux";
        arch = "arm64";
        sha256 = "sha256-vX9MnZLivZ/JSonQYdyK4Z5vAAWPm7bEEjzIHlNLNQU=";
      };
      "x86_64-darwin" = {
        os = "darwin";
        arch = "amd64";
        sha256 = "sha256-xFir/wP1jXKZGFO+HdVLZM/py8y1L1wrdJHZh0jcPpk=";
      };
      "aarch64-darwin" = {
        os = "darwin";
        arch = "arm64";
        sha256 = "sha256-JdsnvqBgnK+Y3cwlD640yq1beWffeNtETBNhvdC31zE=";
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
