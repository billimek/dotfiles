{ ... }:
{
  # fastmcp 3.2.3 fails 3 stateful proxy tests in the nixpkgs build
  # (anyio cancel scope RuntimeError). Skip its test suite; pulled in by mcp-nixos.
  flake.overlays.fastmcp-no-check = _final: prev: {
    pythonPackagesExtensions = (prev.pythonPackagesExtensions or [ ]) ++ [
      (_pyFinal: pyPrev: {
        fastmcp = pyPrev.fastmcp.overridePythonAttrs (_: {
          doCheck = false;
        });
      })
    ];
  };
}
