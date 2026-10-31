{ ... }:
{
  # TEMP-PATCH: fastmcp stateful proxy tests (anyio cancel scope error) and mcp-nixos test_read_text_file (reads /nix/store) fail
  flake.overlays.mcp-no-check = _final: prev: {
    pythonPackagesExtensions = (prev.pythonPackagesExtensions or [ ]) ++ [
      (_pyFinal: pyPrev: {
        fastmcp = pyPrev.fastmcp.overridePythonAttrs (_: {
          doCheck = false;
        });
      })
    ];
    mcp-nixos = prev.mcp-nixos.overridePythonAttrs (_: {
      doCheck = false;
    });
  };
}
