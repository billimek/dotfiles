{
  # place ~/$HOME/Library/Application\ Support/com.mitchellh.ghostty/config file
  home.file."Library/Application Support/com.mitchellh.ghostty/config".text = ''
    clipboard-trim-trailing-spaces = true
    copy-on-select = true

    # use 'fallback' nerdfont symbols font to make default fonts for now because the custom fonts render symbols too small
    # see https://github.com/ghostty-org/ghostty/discussions/3501
    font-family = "Monaspace Neon"
    font-family = "Symbols Nerd Font Mono"

    # font-family = "MonaspiceNe NFM"
    # font-family-bold = "MonaspiceNe NFM Bold"
    # font-family-bold-italic = "MonaspiceRn NFM Bold Italic"
    # font-family-italic = "MonaspiceRn NFM Italic"
    font-size = 15

    keybind = shift+page_down=scroll_page_down
    keybind = shift+page_up=scroll_page_up
    keybind = super+`=toggle_quick_terminal
    keybind = super+left=previous_tab
    keybind = super+right=next_tab

    macos-auto-secure-input = true
    macos-icon = custom-style
    macos-icon-frame = aluminum
    macos-icon-ghost-color = #cd6600
    macos-icon-screen-color = #cd6600
    macos-option-as-alt = true
    macos-secure-input-indication = true
    macos-titlebar-style = tabs

    quit-after-last-window-closed = true
    shell-integration = "detect"
    shell-integration-features = cursor,sudo,title

    #theme = "catppuccin-mocha"
    #theme = Dracula

    window-height = 35
    window-padding-y = 0
    window-save-state = always
    window-theme = ghostty
    # window-title-font-family = "MonaspiceNe NFM"
    window-width = 280
  '';
}
