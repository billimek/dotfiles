# Aliases in this file are bash and zsh compatible

# Get operating system
platform='unknown'
unamestr=$(uname)
if [[ $unamestr == 'Linux' ]]; then
  platform='linux'
elif [[ $unamestr == 'Darwin' ]]; then
  platform='darwin'
fi

# PS
alias psa="ps aux"

# Moving around
alias cdb='cd -'
alias cls='clear;ls'

# Show human friendly numbers and colors
alias df='df -h'
alias du='du -h'

if [[ $platform == 'linux' ]]; then
  alias ll='ls -alh --color=auto'
  alias d='ls -alh --color=auto'
  alias ls='ls --color=auto'
elif [[ $platform == 'darwin' ]]; then
  alias ll='ls -alGh'
  alias d='ls -alGh'
  alias ls='ls -Gh'
fi

alias lc='colorls -lA'

# Git Aliases
alias gs='git status'
alias gsh='git show'
alias gca='git ca'
alias gcm='git ci -m'
#alias gcim='git ci -m'
alias gc='git ci'
alias gci='git ci'
alias gco='git co'
alias ga='git add -A'
alias gap='git add -p'
alias guns='git unstage'
alias gunc='git uncommit'
alias gm='git merge'
alias gms='git merge --squash'
alias gam='git amend --reset-author'
alias grv='git remote -v'
alias grad='git remote add'
alias gl='git l'
alias gd='git diff'
alias gb='git b'
alias gpl='git pull'
alias gplr='git pull --rebase'
alias gp='git push'
alias gpc='git push -u origin `git rev-parse --abbrev-ref HEAD`'
alias gpf='git push --force-with-lease'
alias gbc='git nb' # new branch aka checkout -b
alias gsm='git submodule'
alias gdmb='git branch --merged | grep -v "\*" | xargs -n 1 git branch -d'

# Common shell functions
alias less='less -r'
alias tf='tail -F'
alias l='less'
alias lh='ls -alt | head' # see the last modified files
alias sc='tmux detach;tmux attach'
alias scc='tmux -CC attach'
alias cl='clear'
alias watch='watch '

# Docker
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}"'

