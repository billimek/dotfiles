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
    # can probsbly remove once https://github.com/LnL7/nix-darwin/pull/942 is merged:
    inputs.nh_darwin.nixDarwinModules.prebuiltin
  ];
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
    };

    configureBuildUsers = true;
  };

  services.nix-daemon.enable = true;

  environment = {
    systemPackages = [
      pkgs.coreutils
      pkgs.fish
      pkgs.git
      pkgs.vim
      pkgs.home-manager
    ];
    shells = [
      pkgs.bashInteractive
      pkgs.fish
    ];
    variables = {
      EDITOR = "${lib.getBin pkgs.neovim}/bin/nvim";
      SSH_AUTH_SOCK = "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
      # FLAKE = "/etc/nixos";
    };
  };

  programs = {
    bash.enable = true;
    fish.enable = true;
    zsh.enable = true;
    nix-index.enable = true;
    nh = {
      enable = true;
      clean.enable = true;
      # Installation option once https://github.com/LnL7/nix-darwin/pull/942 is merged:
      # package = nh_darwin.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
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

    NSGlobalDomain = {
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
  security.pam.enableSudoTouchIdAuth = true;

  # Set sudo timestamp timeout
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=30
  '';
}
