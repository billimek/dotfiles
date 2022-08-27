##############################################################################
# Customizations
##############################################################################

# Uncomment following line if you want red dots to be displayed while waiting for completion
export COMPLETION_WAITING_DOTS="true"

## Spaceship Prompt Customizations
export SPACESHIP_EXIT_CODE_SHOW=true
export SPACESHIP_HOST_SHOW=always
export SPACESHIP_KUBECTL_SHOW=true
export SPACESHIP_KUBECTL_VERSION_SHOW=false

export ZSH_CACHE_DIR="$HOME/.cache"

# Correct spelling for commands
setopt correct

# allow tab-completion of aliases
setopt no_complete_aliases

# turn off the infernal correctall for filenames
unsetopt correctall

# Base PATH
PATH=/usr/local/bin:/usr/local/sbin:/sbin:/usr/sbin:/bin:/usr/bin:/Users/jeff/google-cloud-sdk/bin

# Conditional PATH additions
for path_candidate in /opt/local/sbin \
  /Applications/Xcode.app/Contents/Developer/usr/bin \
  /opt/local/bin \
  /opt/homebrew/bin \
  /usr/local/share/npm/bin \
  ~/.cabal/bin \
  ~/.cargo/bin \
  ~/.rbenv/bin \
  ~/bin \
  ~/src/gocode/bin \
  ~/.krew/bin \
  /home/jeff/.local/bin/
do
  if [ -d ${path_candidate} ]; then
    export PATH=${path_candidate}:${PATH}
  fi
done

# Yes, these are a pain to customize. Fortunately, Geoff Greer made an online
# tool that makes it easy to customize your color scheme and keep them in sync
# across Linux and OS X/*BSD at http://geoff.greer.fm/lscolors/

export LSCOLORS='exfxcxdxbxegedabagacad'
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'


##############################################################################
# zgen
##############################################################################
if [ -f ~/.zgen-setup ]; then
  source ~/.zgen-setup
fi

# Keep a ton of history.
HISTSIZE=100000
SAVEHIST=100000
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"

# Long running processes should return time after they complete. Specified
# in seconds.
REPORTTIME=2
TIMEFMT="%U user %S system %P cpu %*Es total"

# Expand aliases inline - see http://blog.patshead.com/2012/11/automatically-expaning-zsh-global-aliases---simplified.html
globalias() {
   if [[ $LBUFFER =~ ' [A-Z0-9]+$' ]]; then
     zle _expand_alias
     zle expand-word
   fi
   zle self-insert
}

zle -N globalias

bindkey " " globalias
bindkey "^ " magic-space           # control-space to bypass completion
bindkey -M isearch " " magic-space # normal space during searches

if [ -r ~/.zsh_aliases ]; then
  source ~/.zsh_aliases
fi

if [ -r ~/.zsh_functions ]; then
  source ~/.zsh_functions
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  # We're on osx
  [ -f ~/.osx_aliases ] && source ~/.osx_aliases
  if [ -d ~/.osx_aliases.d ]; then
    for alias_file in ~/.osx_aliases.d/*
    do
      source $alias_file
    done
  fi
fi

export LOCATE_PATH=/var/db/locate.database

##############################################################################
# zstyle stuff
##############################################################################
# Speed up autocomplete, force prefix mapping
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)*==34=34}:${(s.:.)LS_COLORS}")';
zstyle ':prezto:*:*' case-sensitive 'no'

zstyle ':prezto:*:*' color 'yes'

zstyle ':prezto:module:terminal' auto-title 'yes'
zstyle ':prezto:module:tmux:iterm' integrate 'yes'

# Load any custom zsh completions we've installed
if [ -d ~/.zsh-completions ]; then
  for completion in ~/.zsh-completions/*
  do
    source "$completion"
  done
fi

##############################################################################
# Handle starship prompt
##############################################################################a
if [[ "$OSTYPE" == "freebsd12.0"* ]]; then
  if [ -f /mnt/tank/iocage/jails/ports/root/usr/local/bin/starship ]; then
    export LD_LIBRARY_PATH=/mnt/tank/iocage/jails/ports/root/usr/local/lib
    eval "$(/mnt/tank/iocage/jails/ports/root/usr/local/bin/starship init zsh)"
  fi
else
  eval "$(starship init zsh)"
fi

##############################################################################
# .zshrc.d/ files loading
##############################################################################
# Make it easy to append your own customizations that override the above by
# loading all files from the ~/.zshrc.d directory
mkdir -p ~/.zshrc.d
if [ -n "$(/bin/ls ~/.zshrc.d)" ]; then
  for dotfile in ~/.zshrc.d/*
  do
    if [ -r "${dotfile}" ]; then
      source "${dotfile}"
    fi
  done
fi


source /Users/JKB2462/google-cloud-sdk/path.zsh.inc
source /Users/JKB2462/google-cloud-sdk/completion.zsh.inc
