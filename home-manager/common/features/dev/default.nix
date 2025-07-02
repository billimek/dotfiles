{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # cargo # package manager
    # gcc # compiler
    # gnumake
    # go
    # pkgs.unstable.nodejs
    # rustc # compiler
    uv # nodejs runtime
  ];
  home.sessionPath = [ "$HOME/.cargo/bin" ];
}
