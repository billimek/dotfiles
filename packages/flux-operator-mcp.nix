{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:

let
  version = "0.59.0";
  plat =
    {
      "x86_64-linux" = {
        os = "linux";
        arch = "amd64";
        sha256 = "sha256-VcvmPu2avA7JIkCRn3fmv1m31PGKG0VctJz8Zc6Xm4g=";
      };
      "aarch64-linux" = {
        os = "linux";
        arch = "arm64";
        sha256 = "sha256-pFXChovVuHzaPhJ9S7MXx4MxhcgeDxezfvK6y8nq2pM=";
      };
      "x86_64-darwin" = {
        os = "darwin";
        arch = "amd64";
        sha256 = "sha256-m5QH7a/jWhtuaE0aXJVa56P0eEReUnBmKCUqiYMF0tU=";
      };
      "aarch64-darwin" = {
        os = "darwin";
        arch = "arm64";
        sha256 = "sha256-7rb74qkH4aeTgz2CFpqJi98aFif/joQcVMqanj3pSo8=";
      };
    }
    .${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "flux-operator-mcp";
  inherit version;

  src = fetchurl {
    url = "https://github.com/controlplaneio-fluxcd/flux-operator/releases/download/v${version}/flux-operator-mcp_${version}_${plat.os}_${plat.arch}.tar.gz";
    sha256 = plat.sha256;
  };

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar xzf "$src"
  '';

  installPhase = ''
    install -Dm755 flux-operator-mcp "$out/bin/flux-operator-mcp"
  '';

  meta = {
    description = "MCP server for FluxCD GitOps cluster management";
    homepage = "https://github.com/controlplaneio-fluxcd/flux-operator";
    mainProgram = "flux-operator-mcp";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
