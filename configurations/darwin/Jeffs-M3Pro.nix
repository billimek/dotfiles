# Darwin configuration for Jeff's personal M3 Pro MacBook
{
  pkgs,
  ...
}:
{
  # Enable modules (base and homebrew are auto-enabled)
  modules = {
    # All base darwin modules are auto-enabled
  };

  environment.darwinConfig = "$HOME/src/dotfiles/configurations/darwin/Jeffs-M3Pro.nix";

  networking.hostName = "Jeffs-M3Pro";

  system.primaryUser = "jeff";

  users.users.jeff = {
    description = "Jeff Billimek";
    shell = pkgs.fish;
    home = "/Users/jeff";
  };

  # Additional homebrew packages specific to this machine
  homebrew = {
    casks = [
      "google-chrome"
      "discord"
      "freelens"
      "microsoft-office"
      "microsoft-remote-desktop"
      "moonlight"
      "mudlet"
      "obs"
      "OrbStack"
      "plex"
      "prismlauncher"
      "slack"
      "steam"
      "VIA"
      "vmware-fusion"
      "zoom"
    ];
    masApps = {
      "SteamLink" = 1246969117;
      "paprika-recipe-manager-3" = 1303222628;
    };
  };

  system.stateVersion = 5;
}
