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
  finderDownloadsPath = "file://localhost/Users/${config.system.primaryUser}/Downloads/";
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
      # Workaround for aarch64-darwin codesigning bug (nixpkgs#208951 / #507531):
      # fish binaries from the binary cache occasionally have invalid ad-hoc
      # signatures on Apple Silicon. Forcing a local rebuild ensures codesigning
      # is applied on this machine with a valid signature.
      overlays = [
        (_final: prev: {
          fish = prev.fish.overrideAttrs (_old: {
            # Bust the cache key so fish is always built locally rather than
            # substituted from the binary cache where the signature may be stale.
            NIX_FORCE_LOCAL_REBUILD = "darwin-codesign-fix";
          });
        })
      ];
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
        FlashDateSeparators = true;
        ShowDayOfWeek = true;
        ShowDayOfMonth = true;
        ShowAMPM = false;
      };

      WindowManager = {
        EnableStandardClickToShowDesktop = false;
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
        NSGlassDiffusionSetting = 1;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        "com.apple.sound.beep.feedback" = 1;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
      };

      CustomUserPreferences = {
        "com.apple.finder" = {
          NewWindowTarget = "PfLo";
          NewWindowTargetPath = finderDownloadsPath;
        };
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
