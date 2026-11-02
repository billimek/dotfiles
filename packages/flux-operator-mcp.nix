{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:

let
  version = "0.62.1";
  plat =
    {
      "x86_64-linux" = {
        os = "linux";
        arch = "amd64";
        sha256 = "sha256-E+yFYWnYopBegivfrXYXKCkNe51yw/aKs/ObFQjoAyc=";
      };
      "aarch64-linux" = {
        os = "linux";
        arch = "arm64";
        sha256 = "sha256-aj2TRbJaNmKHnIFYeFS3upoTDo2Os1M3n9ENp5dESn4=";
      };
      "x86_64-darwin" = {
        os = "darwin";
        arch = "amd64";
        sha256 = "sha256-9NRU4ibAUZxX6XWNwEgdpADIUhHeUzvhNK8fYTPWJm8=";
      };
      "aarch64-darwin" = {
        os = "darwin";
        arch = "arm64";
        sha256 = "sha256-E406RdRCSB3xVQRgezY0LbM0ykLYyCAhiBxDwCBhSx8=";
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
