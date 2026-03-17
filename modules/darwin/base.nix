# Base Darwin module - core configurations enabled by default
{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  pkgs-unstable,
  ...
}:
let
  cfg = config.modules.base;
in
{
  # Imports must be at top level (not inside mkIf)
  imports = [
    inputs.opnix.darwinModules.default
  ];

  options.modules.base = {
    enable = lib.mkEnableOption "base darwin configuration" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    # Preserve existing nixbld GID
    ids.gids.nixbld = 30000;

    nixpkgs = {
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };

    # Determinate Nix manages its own daemon and nix.conf; disable nix-darwin's
    # nix management to avoid conflicts.
    nix.enable = false;

    environment = {
      systemPackages = [
        pkgs.coreutils
        pkgs.fish
        pkgs.git
        pkgs.vim
        pkgs.home-manager
        pkgs.nh
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
    };

    fonts.packages = [
      pkgs.monaspace
      pkgs.nerd-fonts.monaspace
      pkgs.nerd-fonts.symbols-only
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
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        _FXShowPosixPathInTitle = false;
        FXPreferredViewStyle = "Nlsv";
        FXDefaultSearchScope = "SCcf";
        ShowStatusBar = true;
        ShowPathbar = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };

      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

      CustomUserPreferences.NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        "com.apple.swipescrolldirection" = false;
        AppleShowAllExtensions = true;
        # InitialKeyRepeat = 18;
        # KeyRepeat = 1;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        "com.apple.sound.beep.feedback" = 1;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
      };

      CustomUserPreferences = {
        "com.googlecode.iterm2" = {
          "PrefsCustomFolder" = "~/.config/iterm2";
          "LoadPrefsFromCustomFolder" = 1;
        };
        "com.apple.desktopservices".DSDontWriteNetworkStores = true;
        "com.apple.desktopservices".DSDontWriteUSBStores = true;
        "digital.twisted.noTunes" = {
          "hideIcon" = 1;
          "replacement" = "/Applications/Spotify.app";
        };
      };
    };

    security.pam.services.sudo_local.touchIdAuth = true;
    security.sudo.extraConfig = ''
      Defaults timestamp_timeout=30
    '';
  };
}
