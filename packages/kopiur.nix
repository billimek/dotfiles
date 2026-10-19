{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  pname = "kopiur";
  version = "0.10.16";

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
    x86_64-linux = "sha256-XFh9U1heXjIchhtn13xys88WUM9z5MVwnZuoj4+2DEc=";
    aarch64-linux = "sha256-qcTHfrgkKAjEAUvDbiSOXzkgftJ49tYXZ9uLYuwvPz4=";
    x86_64-darwin = "sha256-tL01FsnpQ1RzEaAomFBQbxqrR/hzbq1V1wHZNX4POW8=";
    aarch64-darwin = "sha256-QQ/UTYEXF95lruV3l6rn7MemVTG9XOmA4fecIA7SeE4=";
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
