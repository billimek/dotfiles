function update_environment_from_tmux() {
  if [ -n "${TMUX}" ]; then
    eval "$(tmux show-environment -s)"
  fi
}

add-zsh-hook precmd update_environment_from_tmux


eval "$(op completion zsh)"; compdef _op o

