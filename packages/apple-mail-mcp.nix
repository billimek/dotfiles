{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  ...
}:

buildNpmPackage rec {
  pname = "apple-mail-mcp";
  version = "1.5.5";

  src = fetchFromGitHub {
    owner = "sweetrb";
    repo = "apple-mail-mcp";
    # v1.5.5 was not tagged; pin to the merge commit that bumped it
    rev = "c57c6664779dc7145f9beca0a9365ae82914edae";
    hash = "sha256-NpDIfRuvQc4SlvqDjx6Q2ErrmQrXeGHsic8np+ffs6E=";
  };

  npmDepsHash = "sha256-mcSGItc9rg4IRN3P621O22Z44NFENOcutR6x/mcFDYY=";

  # The "prepare" script invokes husky (requires a .git dir, not present in sandbox).
  # Pass --ignore-scripts to npm ci so lifecycle hooks are skipped during dep install;
  # the explicit "build" script (tsc && tsc-alias) still runs via buildNpmPackage's
  # npmBuildScript mechanism.
  npmFlags = [ "--ignore-scripts" ];

  meta = {
    description = "MCP server for reading and sending Apple Mail via AppleScript";
    homepage = "https://github.com/sweetrb/apple-mail-mcp";
    mainProgram = "apple-mail-mcp";
    platforms = lib.platforms.darwin;
  };
}
