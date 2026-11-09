{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  pname = "kopiur";
  version = "0.10.18";

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
    x86_64-linux = "sha256-lwxyHnj9pcJK3WqZPW1DYOXLB5JI2rEHJRiscnO9J+s=";
    aarch64-linux = "sha256-f2uR/CvYyTlS+Ic/UWf0sWlvILDfDlvSAufGz+ODsIs=";
    x86_64-darwin = "sha256-xQuEITAWt7XQqZ5iwdUkkPv5sr5cCpYpZUnfsrcTjHc=";
    aarch64-darwin = "sha256-EHrPN4ewx1hBE8YuJr5xhWesLHYksAGBcA6q4XmzzQA=";
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
