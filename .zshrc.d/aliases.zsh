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
#alias gstsh='git stash'
#alias gst='git stash'
#alias gsp='git stash pop'
#alias gsa='git stash apply'
alias gsh='git show'
#alias gshw='git show'
#alias gshow='git show'
#alias gi='vim .gitignore'
alias gca='git ca'
alias gcm='git ci -m'
#alias gcim='git ci -m'
#alias gci='git ci'
alias gco='git co'
#alias gcp='git cp'
alias ga='git add -A'
alias gap='git add -p'
alias guns='git unstage'
alias gunc='git uncommit'
alias gm='git merge'
alias gms='git merge --squash'
alias gam='git amend --reset-author'
alias grv='git remote -v'
#alias grr='git remote rm'
alias grad='git remote add'
#alias gr='git rebase'
#alias gra='git rebase --abort'
#alias ggrc='git rebase --continue'
#alias gbi='git rebase --interactive'
alias gl='git l'
#alias glg='git l'
#alias glog='git l'
#alias co='git co'
#alias gf='git fetch'
#alias gfp='git fetch --prune'
#alias gfa='git fetch --all'
#alias gfap='git fetch --all --prune'
#alias gfch='git fetch'
alias gd='git diff'
alias gb='git b'
# Staged and cached are the same thing
#alias gdc='git diff --cached -w'
#alias gds='git diff --staged -w'
#alias gpub='grb publish'
#alias gtr='grb track'
alias gpl='git pull'
alias gplr='git pull --rebase'
alias gps='git push'
#alias gpsh='git push -u origin `git rev-parse --abbrev-ref HEAD`'
alias gnb='git nb' # new branch aka checkout -b
#alias grs='git reset'
#alias grsh='git reset --hard'
#alias gcln='git clean'
#alias gclndf='git clean -df'
#alias gclndfx='git clean -dfx'
alias gsm='git submodule'
#alias gsmi='git submodule init'
#alias gsmu='git submodule update'
#alias gt='git t'
#alias gbg='git bisect good'
#alias gbb='git bisect bad'
alias gdmb='git branch --merged | grep -v "\*" | xargs -n 1 git branch -d'

# Common shell functions
alias less='less -r'
alias tf='tail -F'
alias l='less'
alias lh='ls -alt | head' # see the last modified files
alias screen='TERM=screen screen'
alias cl='clear'

# Docker
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}"'

