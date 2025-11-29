# Tmux terminal multiplexer
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.tmux;
in
{
  options.modules.tmux = {
    enable = lib.mkEnableOption "tmux" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      package = pkgs.unstable.tmux;
      terminal = "tmux-256color";
      aggressiveResize = true;
      baseIndex = 1;
      historyLimit = 100000;
      keyMode = "vi";
      mouse = false;
      newSession = true;
      shortcut = "a";
      extraConfig = ''
        set -sa terminal-features ",*256col*:RGB"
        set -s buffer-limit 20
        set -g display-time 1500
        set -g repeat-time 500
        setw -g automatic-rename on
        setw -g automatic-rename-format '#{pane_current_command}'
        setw -g allow-rename off
        setw -g xterm-keys on
        setenv -g SSH_AUTH_SOCK $HOME/.ssh/ssh_auth_sock
        set -g update-environment -r
        setw -g monitor-activity on
        set -g visual-activity off
        set -g renumber-windows on

        bind-key ^D detach-client
        bind e setw synchronize-panes on
        bind E setw synchronize-panes off
        bind-key -r ^N next-window
        bind-key -r ^P previous-window
        bind-key -r ^D detach-client
        bind-key -n S-Left  previous-window
        bind-key -n S-Right next-window
        bind k confirm-before kill-window
        bind K kill-window
        unbind l
        bind c new-window -c "#{pane_current_path}"
        set -g assume-paste-time 0
        unbind r
        bind r source-file ~/.tmux.conf \; display "Reloaded!"

        set -g status-left-length 52
        set -g status-right-length 451
        set -g status-fg white
        set -g status-bg colour234
        set -g status-left '#[fg=colour235,bg=colour252,bold] ❐ #S #[fg=colour252,bg=colour238,nobold]#[fg=colour245,bg=colour238,bold] #(whoami) #[fg=colour238,bg=colour234,nobold]'
        set -g window-status-format "#[fg=colour252,bg=colour235,bold] #I #W"
        set -g window-status-current-format "#[fg=colour234,bg=colour39]#[fg=colour234,bg=colour39,noreverse,nobold] #{?window_zoomed_flag,#[fg=colour226],} #I: #W #[fg=colour39,bg=colour234,nobold]"
        set-option -g status-interval 2

        if-shell "[ -f ~/.tmux.conf.user ]" 'source ~/.tmux.conf.user'
      '';
    };
  };
}
