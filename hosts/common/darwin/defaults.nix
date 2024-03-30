{ config, pkgs, lib, pkgs-unstable, ... }: {
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
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
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
    systemPackages =
      [ pkgs.coreutils pkgs.fish pkgs.git pkgs.vim pkgs.home-manager ];
    shells = [ pkgs.bashInteractive pkgs.fish ];
    variables.EDITOR = "${lib.getBin pkgs.neovim}/bin/nvim";
    variables.SSH_AUTH_SOCK =
      "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  };

  programs = {
    bash.enable = true;
    fish.enable = true;
    zsh.enable = true;
  };

  # add nerd fonts
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs;
    [ (pkgs-unstable.nerdfonts.override { fonts = [ "Hack" "Monaspace" ]; }) ];

  #system-defaults.nix
  # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
  # system.activationScripts.postUserActivation.text = ''
  #   # activateSettings -u will reload the settings from the database and apply them to the current session,
  #   # so we do not need to logout and login again to make the changes take effect.
  #   /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  # '';

  system.keyboard = { enableKeyMapping = true; };
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
      FXEnableExtensionChangeWarning =
        false; # disable warning when changing file extensions
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
      "com.apple.swipescrolldirection" =
        false; # set natural scrolling to the _correct_ value

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
      "com.apple.Safari" = {
        "IncludeInternalDebugMenu" = true;
        "IncludeDevelopMenu" = true;
        "WebKitDeveloperExtrasEnabledPreferenceKey" = true;
        "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" =
          true;
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
