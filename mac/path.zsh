# Append necessary path to PATH for Mac.

if [ "$(uname)" = 'Darwin' ]; then
  # nvm configuration.
  export NVM_DIR=~/.nvm
  source $(brew --prefix nvm)/nvm.sh
  alias cat='ccat'
fi
