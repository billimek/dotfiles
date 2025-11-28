{
  programs.ghostty = {
    enable = true;

    # Set to null on Darwin since ghostty package is marked as broken
    # You can install Ghostty separately (e.g., from the app or building manually)
    # This module will still manage your config at $XDG_CONFIG_HOME/ghostty/config
    package = null;

    # Enable shell integrations for better terminal experience
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    settings = {
      clipboard-trim-trailing-spaces = true;
      copy-on-select = "clipboard";
      cursor-style = "block";

      # use 'fallback' nerdfont symbols font to make default fonts for now because the custom fonts render symbols too small
      # see https://github.com/ghostty-org/ghostty/discussions/3501
      # Note: duplicate keys like font-family must be specified as a list
      font-family = [
        "Monaspace Neon"
        "Symbols Nerd Font Mono"
      ];

      font-size = 15;

      # Claude Code Shift+Enter support - sends ESC + CR
      # See: https://github.com/anthropics/claude-code/issues/1282
      keybind = [
        "shift+enter=text:\\x1b\\r"
        "shift+page_down=scroll_page_down"
        "shift+page_up=scroll_page_up"
        "super+`=toggle_quick_terminal"
        "super+left=previous_tab"
        "super+right=next_tab"
      ];

      macos-auto-secure-input = true;
      macos-icon = "custom-style";
      macos-icon-frame = "aluminum";
      macos-icon-ghost-color = "#cd6600";
      macos-icon-screen-color = "#cd6600";
      macos-option-as-alt = true;
      macos-secure-input-indication = true;
      macos-titlebar-style = "tabs";

      quit-after-last-window-closed = true;
      shell-integration = "fish";
      shell-integration-features = "no-cursor,sudo,title,ssh-terminfo,ssh-env";

      # term = "xterm-256color";

      # theme = "catppuccin-mocha";
      # theme = "Dracula";

      window-height = 35;
      window-padding-y = 0;
      window-save-state = "always";
      window-theme = "ghostty";
      window-width = 280;
    };
  };
}
