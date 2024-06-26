{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cargo # package manager
    gcc # compiler
    gnumake
    go
    nodejs
    rustc # compiler
  ];
  home.sessionPath = [ "$HOME/.cargo/bin" ];
}
