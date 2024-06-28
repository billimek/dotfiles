{
  pkgs,
  lib,
  config,
  ...
}:
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    aggressiveResize = true;
    baseIndex = 1;
    historyLimit = 100000;
    keyMode = "vi";
    mouse = false; # set to true if you like pain
    newSession = true;
    shortcut = "a";
    extraConfig = ''
      #
      # GENERAL SETTINGS
      #
      # True color support
      set -sa terminal-features ",*256col*:RGB"
      # Undercurl support
      # set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
      # Underscore colors
      # set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
      # Number of buffers, older than limit buffer will be removed
      set -s buffer-limit 20
      # Time for which status line messages and indicators are displayed in miliseconds, 0 means diplay until a key is pressed
      set -g display-time 1500
      # Typing command without pressing prefix key again in the specified time in miliseconds
      set -g repeat-time 500
      # Automatic window renaming
      setw -g automatic-rename on
      # Format of automatic window renaming
      setw -g automatic-rename-format '#{pane_current_command}'
      # Allow programs to change the window name
      setw -g allow-rename off
      # Xterm style function key sequences
      setw -g xterm-keys on
      # Ring the bell if any background window rang a bell
      #set -g bell-action any
      # Help SSH agent forwarding
      setenv -g SSH_AUTH_SOCK $HOME/.ssh/ssh_auth_sock
      set -g update-environment -r
      # Monitor window activity. Windows with activity are highlighted in the status line:
      setw -g monitor-activity on
      # Prevent Tmux from displaying the annoying Activity in window X messages:
      set -g visual-activity off
      # Automatically set window title
      # set-option -g set-titles on
      # Automatically re-number windows after one of them is closed.
      set -g renumber-windows on


      #
      # KEY BINDINGS
      #
      # Keep your finger on ctrl, or don't
      bind-key ^D detach-client

      # Create splits and vertical splits
      # bind-key v split-window -h -p 50 -c "#{pane_current_path}"
      # bind-key ^V split-window -h -p 50 -c "#{pane_current_path}"
      # bind-key s split-window -p 50 -c "#{pane_current_path}"
      # bind-key ^S split-window -p 50 -c "#{pane_current_path}"

      # Pane resize in all four directions using vi bindings.
      # Can use these raw but I map them to shift-ctrl-<h,j,k,l> in iTerm.
      # bind -r H resize-pane -L 5
      # bind -r J resize-pane -D 5
      # bind -r K resize-pane -U 5
      # bind -r L resize-pane -R 5

      # easily toggle synchronization (mnemonic: e is for echo)
      # sends input to all panes in a given window.
      bind e setw synchronize-panes on
      bind E setw synchronize-panes off

      bind-key -r ^N next-window
      bind-key -r ^P previous-window
      bind-key -r ^D detach-client
      bind-key -n S-Left  previous-window
      bind-key -n S-Right next-window

      bind k confirm-before kill-window
      bind K kill-window

      # Screen like binding for last window
      unbind l

      # New windows/pane in $PWD
      bind c new-window -c "#{pane_current_path}"

      # Fix key bindings broken in tmux 2.1
      set -g assume-paste-time 0

      # force a reload of the config file
      unbind r
      bind r source-file ~/.tmux.conf \; display "Reloaded!"

      # mouse mode in case you are a sadist
      #set-window-option -g mouse on
      #set -g mouse on
      # bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'select-pane -t=; copy-mode -e; send-keys -M'"
      # bind -n WheelDownPane select-pane -t= \; send-keys -M

      #
      # STATUS BAR
      #
      # color scheme (styled as vim-powerline)
       set -g status-left-length 52
       set -g status-right-length 451
       set -g status-fg white
       set -g status-bg colour234
       set -g status-left '#[fg=colour235,bg=colour252,bold] ❐ #S #[fg=colour252,bg=colour238,nobold]#[fg=colour245,bg=colour238,bold] #(whoami) #[fg=colour238,bg=colour234,nobold]'
       set -g window-status-format "#[fg=colour252,bg=colour235,bold] #I #W"
       set -g window-status-current-format "#[fg=colour234,bg=colour39]#[fg=colour234,bg=colour39,noreverse,nobold] #{?window_zoomed_flag,#[fg=colour226],} #I: #W #[fg=colour39,bg=colour234,nobold]"
       set-option -g status-interval 2

      # Local config
      if-shell "[ -f ~/.tmux.conf.user ]" 'source ~/.tmux.conf.user'
    '';
  };
}
