#!/usr/bin/env bash

function print_header() {
  echo "##############################"
  echo $1
  echo "##############################"
}

# OS Specific Setup with yadm
if [[ "$OSTYPE" == "darwin"* ]]; then
  print_header "Install Homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  print_header "Install yadm and clone the dotfiles repo"
  brew install yadm
  yadm clone git@github.com:billimek/dotfiles.git
  yadm submodule init
  yadm submodule update --recursive
else
  print_header "Install yadm and clone the dotfiles repo"
  sudo apt-get install yadm -y
  yadm clone git@github.com:billimek/dotfiles.git
  yadm submodule init
  yadm submodule update --recursive
fi
