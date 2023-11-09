{
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      window = {
        dimensions = {
          columns = 255;
          lines = 35;
        };
        padding = {
          x = 10;
          y = 10;
        };
      };
      scrolling.history = 10000;

      key_bindings = [
        {
          # clear terminal
          key = "L";
          mods = "Control";
          chars = "\\x0c";
        }
      ];

      font = let
        fontname = "Hack Nerd Font";
      in {
        normal = {
          family = fontname;
          style = "Regular";
        };
        bold = {
          family = fontname;
          style = "Bold";
        };
        italic = {
          family = fontname;
          style = "Italic";
        };
        size = 16;
      };

      # draw_bold_text_with_bright_colors = true;

      # Colors (Tomorrow Night)
      colors = {
        primary = {
          background = "0x1d1f21";
          foreground = "0xc5c8c6";
          #   bright_foreground = "#f9f5d7";
          #   dim_foreground = "#f2e5bc";
        };
        cursor = {
          text = "0x1d1f21";
          cursor = "0xffffff";
        };
        # vi_mode_cursor = {
        #     text = "CellBackground";
        #     cursor = "CellForeground";
        # };
        # selection = {
        #     text = "CellBackground";
        #     background = "CellForeground";
        # };
        normal = {
          black = "0x1d1f21";
          red = "0xcc6666";
          green = "0xb5bd68";
          yellow = "0xe6c547";
          blue = "0x81a2be";
          magenta = "0xb294bb";
          cyan = "0x70c0ba";
          white = "0x373b41";
        };
        bright = {
          black = "0x666666";
          red = "0xff3334";
          green = "0x9ec400";
          yellow = "0xf0c674";
          blue = "0x81a2be";
          magenta = "0xb77ee0";
          cyan = "0x54ced6";
          white = "0x282a2e";
        };
      };

      # bell.duration = 0;
      live_config_reload = true;

      # selection settings
      selection.save_to_clipboard = true;

      # cursor settings
      cursor = {
        style.shape = "Underline";
        unfocused_follow = false;
      };

      # mouse settings
      mouse_bindings = [
        {
          mouse = "Middle";
          action = "PasteSelection";
        }
      ];
    };
  };
}
