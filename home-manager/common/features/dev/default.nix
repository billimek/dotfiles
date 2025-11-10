{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # cargo # package manager
    # gcc # compiler
    # gnumake
    # go
    # pkgs.unstable.nodejs
    # rustc # compiler
    pkgs.unstable.claude-code
    python311Packages.pyyaml
    uv # nodejs runtime
  ];
  home.sessionPath = [ "$HOME/.cargo/bin" ];
}
