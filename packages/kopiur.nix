{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  pname = "kopiur";
  version = "0.10.7";

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
    x86_64-linux = "sha256-osbivedXepvPA5ZESIrxcrE547rF3hAWpO4uzqXoAck=";
    aarch64-linux = "sha256-oFccPSdYhZrWp4AOBEamSy6a+n3E1k08HLQ8Qj1qW7U=";
    x86_64-darwin = "sha256-gj8l/BhDN+o8o2gaSY33x8elE9/RgmosX66zE8xfuP8=";
    aarch64-darwin = "sha256-tYA1M2DO90K5KLKnPh/hB2TGY5AV9YMDFrODdEoZl/I=";
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
