{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  pname = "kopiur";
  version = "0.10.13";

  selectSystem =
    attrs:
    attrs.${stdenvNoCC.hostPlatform.system}
      or (throw "${pname}: unsupported system ${stdenvNoCC.hostPlatform.system}");

  suffix = selectSystem {
    x86_64-linux = "linux_amd64";
    aarch64-linux = "linux_arm64";
    x86_64-darwin = "darwin_amd64";
    aarch64-darwin = "darwin_arm64";
  };

  hash = selectSystem {
    x86_64-linux = "sha256-knH0tBVq/5UH3W9LPVV15GmdnnGwcBRLe5v0LfTY8aY=";
    aarch64-linux = "sha256-g+QQW4v/UV6opQzZ1ukBrGHlpdIqSC4UH/6JE+6BI04=";
    x86_64-darwin = "sha256-uFsbbiG8yxPe+Fg+MWTyO56dAhDIuU3AXE883G3cmZ8=";
    aarch64-darwin = "sha256-V1Fd/3yk6z5zq7/YxkUmFEnokuIz0X/LefCi/f1ap4Y=";
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/home-operations/kopiur/releases/download/${version}/kubectl-kopiur_${version}_${suffix}.tar.gz";
    inherit hash;
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 kopiur $out/bin/kopiur
    ln -s $out/bin/kopiur $out/bin/kubectl-kopiur
    runHook postInstall
  '';

  meta = {
    description = "Kubectl plugin operating the kopiur Kopia-native backup operator";
    mainProgram = "kopiur";
    homepage = "https://kopiur.home-operations.com/cli/";
    changelog = "https://github.com/home-operations/kopiur/blob/${version}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
