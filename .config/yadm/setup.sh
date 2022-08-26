#!/usr/bin/env sh
set -e

print_header() {
  echo "##############################"
  echo "$1"
  echo "##############################"
}

# OS Specific Setup with yadm

if [[ "$CODESPACES" = "true" ]]; then
  print_header "In a codespaces environment"
  # only execute if this is the first time
  if ! which yadm; then
    echo "installing yadm"
    sudo curl -fLo /usr/local/bin/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm && sudo chmod a+x /usr/local/bin/yadm

    echo "removing conflicting dotfiles"
    mv ~/.gitconfig ~/.gitconfig.orig
    mv ~/.zshrc ~/.zshrc.orig

    echo "initialize yadm"
    /usr/local/bin/yadm clone https://github.com/billimek/dotfiles.git --no-bootstrap
    /usr/local/bin/yadm submodule init
    /usr/local/bin/yadm submodule update --recursive

    echo "install starship prompt"
    curl -fsSL https://starship.rs/install.sh | bash -s -- -f

    echo "changing shell to zsh"
    sudo chsh -s /usr/bin/zsh codespace
  fi
  # exit setup script early
  exit 0
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  if ! which /opt/homebrew/bin/brew; then
    echo "=============== Installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  print_header "Install yadm and clone the dotfiles repo (MacOS)"
  /opt/homebrew/bin/brew install yadm
  /opt/homebrew/bin/yadm clone https://github.com/billimek/dotfiles.git
  /opt/homebrew/bin/yadm submodule init
  /opt/homebrew/bin/yadm submodule update --recursive
else
  print_header "Install yadm and clone the dotfiles repo (linux)"
  if ! which yadm; then
    sudo apt-get install yadm -y
  fi
  yadm clone https://github.com/billimek/dotfiles.git
  yadm submodule init
  yadm submodule update --recursive
fi
