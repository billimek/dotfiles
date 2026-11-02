{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  pname = "kopiur";
  version = "0.10.17";

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
    x86_64-linux = "sha256-UyWng14hZpuDFxBo5Iw5AAHvcp7Wqv++ztKwBcUublE=";
    aarch64-linux = "sha256-7k/YSXTy18/o+/rj/qdYW+u23SzrGf3lUPho2sNUPsY=";
    x86_64-darwin = "sha256-yMsx4N6/+0xExMCEU9j7Gx7LSDCUIMQEhpq0cq1pBCA=";
    aarch64-darwin = "sha256-Ys/kh2HT1Ga2xwgo/Lr908sBuMToXO1R+gDjV/kd6qE=";
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
