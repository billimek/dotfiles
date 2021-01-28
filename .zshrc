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
    export PATH=${PATH}:${path_candidate}
  fi
done

# Yes, these are a pain to customize. Fortunately, Geoff Greer made an online
# tool that makes it easy to customize your color scheme and keep them in sync
# across Linux and OS X/*BSD at http://geoff.greer.fm/lscolors/

#export LSCOLORS='Exfxcxdxbxegedabagacad'
export LSCOLORS='exfxcxdxbxegedabagacad'
#export LS_COLORS='di=1;34;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:'
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

##############################################################################
# SSH Handling (TODO)
##############################################################################
#echo
#echo "Current SSH Keys:"
#ssh-add -l
#echo

# Fun with SSH
#if [ $(ssh-add -l | grep -c "The agent has no identities." ) -eq 1 ]; then
#  if [[ "$(uname -s)" == "Darwin" ]]; then
#    # We're on OS X. Try to load ssh keys using pass phrases stored in
#    # the OSX keychain.
#    #
#    # You can use ssh-add -K /path/to/key to store pass phrases into
#    # the OSX keychain
#    ssh-add -k
#  fi
#fi

#for key in $(find ~/.ssh -type f -a \( -name id_rsa -o -name id_dsa -name id_ecdsa \))
#do
#  if [ -f ${key} -a $(ssh-add -l | grep -c "${key//$HOME\//}" ) -eq 0 ]; then
#    ssh-add ${key}
#  fi
#done

# Now that we have $PATH set up and ssh keys loaded, configure zgen.

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

zstyle ':prezto:module:ssh-agent' forwarding 'yes'
#zstyle :omz:plugins:ssh-agent osx-use-launchd-ssh-agent yes
#zstyle :omz:plugins:ssh-agent agent-forwarding on
#zstyle :omz:plugins:ssh-agent identities id_ed25519
# zstyle ':prezto:module:gpg-agent:auto-start' remote 'no'

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
##############################################################################
eval "$(starship init zsh)"

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


