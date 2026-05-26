{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:

let
  version = "1.9.0";
  plat =
    {
      "x86_64-linux" = {
        os = "Linux";
        arch = "x86_64";
        sha256 = "sha256-ZvaMB/eA7EHJKD3xnR33engkoYMP3NtLal67hPCx+HE=";
      };
      "aarch64-linux" = {
        os = "Linux";
        arch = "arm64";
        sha256 = "sha256-NcTNvyjqtiwNwWDWQAGn4W9t1faGifhUMOiRSdcrUHg=";
      };
      "x86_64-darwin" = {
        os = "Darwin";
        arch = "x86_64";
        sha256 = "sha256-IrWPajlBUY3upI91a8JNlovAB9RRhX6tGugvHocBDVs=";
      };
      "aarch64-darwin" = {
        os = "Darwin";
        arch = "arm64";
        sha256 = "sha256-YB7bxfukpvGLti5Nvt75tr9VZgtjW3vI9iy3w0kLw2E=";
      };
    }
    .${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "mcp-victorialogs";
  inherit version;

  src = fetchurl {
    url = "https://github.com/VictoriaMetrics-Community/mcp-victorialogs/releases/download/v${version}/mcp-victorialogs_${plat.os}_${plat.arch}.tar.gz";
    sha256 = plat.sha256;
  };

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar xzf "$src"
  '';

  installPhase = ''
    install -Dm755 mcp-victorialogs "$out/bin/mcp-victorialogs"
  '';

  meta = {
    description = "MCP server for VictoriaLogs log inspection and LogQL querying";
    homepage = "https://github.com/VictoriaMetrics-Community/mcp-victorialogs";
    mainProgram = "mcp-victorialogs";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
