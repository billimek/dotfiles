{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:

let
  version = "0.61.0";
  plat =
    {
      "x86_64-linux" = {
        os = "linux";
        arch = "amd64";
        sha256 = "sha256-rJ7GFl5Eqvv2Aqr/u/QPQLlb9vsXoxcpWOweFLN5jlg=";
      };
      "aarch64-linux" = {
        os = "linux";
        arch = "arm64";
        sha256 = "sha256-bh2Ke/IkXWHAhNAl7JwVRSdWxx27hQr0dnc9MfH4VkM=";
      };
      "x86_64-darwin" = {
        os = "darwin";
        arch = "amd64";
        sha256 = "sha256-Ahy0fxETDJUhO+4fRWxDvvzAqg78+3fqePbTdoaa2JY=";
      };
      "aarch64-darwin" = {
        os = "darwin";
        arch = "arm64";
        sha256 = "sha256-nKdWLgQRV3sJAi0uxDAztBIV2gbw8vpdn8sScAtOnK8=";
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
