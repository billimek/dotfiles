{
  config,
  pkgs,
  lib,
  ...
}: {
  #package config
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    # package = lib.mkDefault pkgs.nix;
    package = pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes" "repl-flake"];
      warn-dirty = false;
      sandbox = "relaxed";
    };

    configureBuildUsers = true;

    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
  };

  services.activate-system.enable = true;
  services.nix-daemon.enable = true;
  programs.nix-index.enable = true;

  environment = {
    systemPackages = [
      pkgs.coreutils
      pkgs.fish
      pkgs.git
      pkgs.vim
      pkgs.home-manager
    ];
    shells = [pkgs.bashInteractive pkgs.fish];
    variables.EDITOR = "${lib.getBin pkgs.neovim}/bin/nvim";
    variables.SSH_AUTH_SOCK = "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  };

  programs = {
    bash.enable = true;
    fish.enable = true;
    zsh.enable = true;
  };

  # add nerd fonts
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    (nerdfonts.override {fonts = ["Hack"];})
  ];

  #system-defaults.nix
  system.keyboard = {
    enableKeyMapping = true;
  };
  system.defaults = {
    menuExtraClock = {
      ShowDayOfWeek = true;
      ShowDayOfMonth = true;
      ShowAMPM = false;
    };
    dock = {
      autohide = true;
      tilesize = 64;
    };
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      _FXShowPosixPathInTitle = true;
    };
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
      # Dragging = true;
    };
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark"; # set dark mode
      "com.apple.swipescrolldirection" = false; # set natural scrolling to the _correct_ value
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 18;
      KeyRepeat = 1;
    };
    CustomUserPreferences = {
      # Manage iTerm with files in ~/.config/iterm2
      "com.googlecode.iterm2" = {
        "PrefsCustomFolder" = "~/.config/iterm2";
        "LoadPrefsFromCustomFolder" = 1;
      };
    };
  };

  # Add flake support and apple silicon stuff
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    extra-platforms = aarch64-darwin x86_64-darwi
  '';

  # Use touch ID for sudo auth
  security.pam.enableSudoTouchIdAuth = true;
}
