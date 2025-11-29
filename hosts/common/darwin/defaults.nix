{
  inputs,
  pkgs,
  lib,
  pkgs-unstable,
  ...
}:
{
  imports = [
    ./homebrew.nix
    inputs.opnix.darwinModules.default
  ];

  # Preserve existing nixbld GID (changed from 30000 to 350 in newer nix-darwin)
  ids.gids.nixbld = 30000;
  #package config
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
      # false until https://github.com/NixOS/nix/issues/11002 is truly resolved
      # sandbox = false;

      substituters = [
        "https://cache.nixos.org/" # official binary cache (yes the trailing slash is really neccacery)
        "https://nix-community.cachix.org" # nix-community cache
        "https://nixpkgs-unfree.cachix.org" # unfree-package cache
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
      ];
    };

  };

  environment = {
    systemPackages = [
      pkgs.coreutils
      pkgs.fish
      pkgs.git
      pkgs.vim
      pkgs.home-manager
      pkgs-unstable.nh
      inputs.opnix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    shells = [
      pkgs.bashInteractive
      pkgs.fish
    ];
    variables = {
      SSH_AUTH_SOCK = "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    };
  };

  programs = {
    bash.enable = true;
    fish.enable = true;
    zsh.enable = true;
    # TODO: Uncomment when programs.nh becomes available in nix-darwin
    # See: https://github.com/nix-darwin/nix-darwin/pull/942 or check for nh module support
    # nh = {
    #   enable = true;
    #   clean.enable = true;
    # };
  };

  # add nerd fonts
  fonts.packages = [
    pkgs-unstable.monaspace
    pkgs-unstable.nerd-fonts.monaspace
    pkgs-unstable.nerd-fonts.symbols-only
  ];

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
      AppleShowAllExtensions = true; # show all file extensions
      FXEnableExtensionChangeWarning = false; # disable warning when changing file extensions
      _FXShowPosixPathInTitle = false; # show full path in title bar
      FXPreferredViewStyle = "Nlsv"; # list view
      FXDefaultSearchScope = "SCcf"; # search current folder by default
      ShowStatusBar = true; # show status bar
      ShowPathbar = true; # show path bar
    };

    # trackpad
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
      # Dragging = true;
    };

    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

    CustomUserPreferences.NSGlobalDomain = {
      AppleInterfaceStyle = "Dark"; # set dark mode
      "com.apple.swipescrolldirection" = false; # set natural scrolling to the _correct_ value

      # show all file extensions
      AppleShowAllExtensions = true;

      # set key repeat to be faster
      InitialKeyRepeat = 18; # default: 68
      KeyRepeat = 1; # default: 6

      # disable some auto-correct behaviors
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      # NSAutomaticPeriodSubstitutionEnabled = false;
      # NSAutomaticQuoteSubstitutionEnabled = false;
      # NSAutomaticSpellingCorrectionEnabled = false;

      # Make a feedback sound when the system volume changed. This setting accepts the integers 0 or 1. Defaults to 1
      "com.apple.sound.beep.feedback" = 1;

      # expand save panel by default
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;

      # expand print panel by default
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
    };

    CustomUserPreferences = {
      # Manage iTerm with files in ~/.config/iterm2
      "com.googlecode.iterm2" = {
        "PrefsCustomFolder" = "~/.config/iterm2";
        "LoadPrefsFromCustomFolder" = 1;
      };
      # Disable Creation of Metadata Files on Network Volumes
      "com.apple.desktopservices".DSDontWriteNetworkStores = true;
      # Disable Creation of Metadata Files on USB Volumes
      "com.apple.desktopservices".DSDontWriteUSBStores = true;
      # safari should enable dev mode
      # "com.apple.Safari" = {
      #   "IncludeInternalDebugMenu" = true;
      #   "IncludeDevelopMenu" = true;
      #   "WebKitDeveloperExtrasEnabledPreferenceKey" = true;
      #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
      # };
      # https://github.com/tombonez/noTunes
      # hides the menubar icon and replaces the default music app with Spotify
      "digital.twisted.noTunes" = {
        "hideIcon" = 1;
        "replacement" = "/Applications/Spotify.app";
      };
    };
  };

  # Add flake support and apple silicon stuff
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    extra-platforms = aarch64-darwin x86_64-darwin
  '';

  # Use touch ID for sudo auth
  security.pam.services.sudo_local.touchIdAuth = true;

  # Set sudo timestamp timeout
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=30
  '';
}
