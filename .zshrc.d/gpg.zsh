export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
gpg-connect-agent updatestartuptty /bye > /dev/null

#if [[ $OSTYPE == darwin* ]]; then
#  _GPG_AGENT_SOCK="${HOME}/.gnupg/S.gpg-agent"
#  _GPG_AGENT_SSH_SOCK="${HOME}/.gnupg/S.gpg-agent.ssh"
#elif [[ $OSTYPE == linux* ]]; then
#  _GPG_AGENT_SOCK="${XDG_RUNTIME_DIR}/.gnupg/S.gpg-agent"
#  _GPG_AGENT_SSH_SOCK="${XDG_RUNTIME_DIR}/.gnupg/S.gpg-agent.ssh"
#fi

