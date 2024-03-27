{ pkgs, ... }: {
  programs.gh = {
    enable = true;
    extensions = with pkgs.unstable; [gh-copilot];
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };
}
