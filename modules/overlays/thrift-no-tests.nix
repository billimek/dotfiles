{ ... }:
{
  # thrift 0.24.0 fails to build on aarch64-darwin: its compiler unit tests do
  # not compile against libcxx 21 (Catch2 RNG assertion) or on arm64 inline asm.
  # Pulled in via mcp-nixos -> fastmcp -> duckdb -> pyarrow -> arrow-cpp.
  flake.overlays.thrift-no-tests = _final: prev: {
    thrift = prev.thrift.overrideAttrs (old: {
      doCheck = false;
      cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DBUILD_TESTING=OFF" ];
    });
  };
}
