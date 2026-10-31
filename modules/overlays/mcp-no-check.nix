{ ... }:
{
  # Skip test suites that fail in the nixpkgs build of mcp-nixos and its dependency fastmcp:
  # fastmcp 3.2.3 stateful proxy tests (anyio cancel scope RuntimeError), and
  # mcp-nixos test_read_text_file (reads an arbitrary /nix/store file).
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
