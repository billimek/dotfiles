{ config, pkgs, ... }:

{
  # Enable WezTerm
  programs.wezterm = {
    enable = true;
    
    # Basic configuration
    extraConfig = ''
      local wezterm = require 'wezterm'

      wezterm.on('gui-startup', function(cmd)
        local tab, pane, window = wezterm.mux.spawn_window {
          position = {
            x = 0,
            y = 2000,
            -- Optional origin to use for x and y.
            -- Possible values:
            -- * "ScreenCoordinateSystem" (this is the default)
            -- * "MainScreen" (the primary or main screen)
            -- * "ActiveScreen" (whichever screen hosts the active/focused window)
            -- * {Named="HDMI-1"} - uses a screen by name. See wezterm.gui.screens()
            origin = "MainScreen"
          },
        }
      end)

      return {
        hide_tab_bar_if_only_one_tab = true,
        -- Set font to MonaspiceNe Nerd Font
        font = wezterm.font("MonaspiceNe Nerd Font"),
        font_size = 15.0,
  
        -- Set color scheme to Dracula (Official)
        color_scheme = 'Dracula (Official)',
        --color_scheme = "Tomorrow Night (Gogh)",

        -- Set the initial size of the window
        initial_cols = 480,  -- Number of columns
        initial_rows = 35,   -- Number of rows

        -- Set the window to occupy the full width of the display
        window_padding = {
            left = 2,
            right = 2,
            top = 2,
            bottom = 2,
        },

        -- This will set the window size on startup
        window_decorations = "RESIZE",

        -- Key bindings
        keys = {
          {
            key = 'LeftArrow',
            mods = 'CMD',
            action = wezterm.action.ActivateTabRelative(-1),
          },
          {
            key = 'RightArrow',
            mods = 'CMD',
            action = wezterm.action.ActivateTabRelative(1),
          },
          {
            key = 'a',
            mods = 'CMD|CTRL',
            action = wezterm.action.SpawnCommandInNewTab {
              -- domain = { DomainName = 'SSH:home' },
              args = { 'ssh', 'home' },
            },
          },
          {
            key = 'b',
            mods = 'CMD|CTRL',
            action = wezterm.action.SpawnCommandInNewTab {
              -- domain = { DomainName = 'SSH:home-ts' },
              args = { 'ssh', 'home-ts' },
            },
          },
          {
            key = 'c',
            mods = 'CMD|CTRL',
            action = wezterm.action.SpawnCommandInNewTab {
              -- domain = { DomainName = 'SSH:cloud' },
              args = { 'ssh', 'cloud' },
            },
          },
        },
      }
    '';
  };
}