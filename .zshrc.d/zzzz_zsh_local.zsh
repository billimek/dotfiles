# Load any custom after code local to the machine
if [ -d $HOME/.zsh.local/ ]; then
  if [ "$(ls -A $HOME/.zsh.local/)" ]; then
    for config_file ($HOME/.zsh.local/*.zsh) source $config_file
  fi
fi
