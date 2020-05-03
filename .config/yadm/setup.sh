#!/usr/bin/env sh
set -e

print_header() {
  echo "##############################"
  echo "$1"
  echo "##############################"
}

# OS Specific Setup with yadm
if [[ "$OSTYPE" = "darwin"* ]]; then
  if ! which brew; then
    echo "=============== Installing homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  print_header "Install yadm and clone the dotfiles repo"
  brew install yadm
  yadm clone https://github.com/billimek/dotfiles.git
  yadm submodule init
  yadm submodule update --recursive
else
  print_header "Install yadm and clone the dotfiles repo"
  if ! which yadm; then
    sudo apt-get install yadm -y
  fi
  yadm clone https://github.com/billimek/dotfiles.git
  yadm submodule init
  yadm submodule update --recursive
fi
