#!/usr/bin/env bash
#Install necessary softwares for Mac here.

# gem install teamocil pygments.rb
# mkdir -p ~/.teamocil

# Check if homebrew get installed.
#if [ ! $(command_exists brew) ]; then
#  echo "  Installing homebrew for you..."
#  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
#fi

# Make sure we are using the lates homebrew.
brew update

# Install homebrew packages
#brew install coreutils git git-lfs git-extras cocoapods tig
#sudo ln -s $(brew --prefix)/bin/gsha256sum $(brew --prefix)/bin/sha256sum

# Install some other useful utilities like `sponge`.
#brew install moreutils findutils
# Install GNU `sed`, overwriting the built-in `sed`.
#brew install gnu-sed --with-default-names

# Install Bash 4.
# Note: don’t forget to add `$(brew --prefix)/bin/bash` and `$(brew --prefix)/bin/zsh`
# to `/etc/shells` before running `chsh`.
#brew tap homebrew/versions
#brew tap oclint/formulae
#brew tap caskroom/cask
#brew tap buo/cask-upgrade
#brew install wget --with-iri
#brew install vim --with-client-server

brew install bash zsh tmux bash-completion2 bash-git-prompt shellcheck xctool ssh-copy-id tree autojump reattach-to-user-namespace gitup ag htop bat mobile-shell ghi yarn mas z exa fd fzf ack prettyping diff-so-fancy ncdu tldr pyenv mosh gibo

# To install useful key bindings and fuzzy completion
$(brew --prefix)/opt/fzf/install

# setup pyenv
local pyenv_versions="2.7.17 3.8.2"
pyenv install $pyenv_versions
pyenv global $pyenv_versions

diff-so-fancy --set-defaults

# Install iTerm2 integrations
curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash

# Upgrade any already-installed formulae.
#brew upgrade --all

# Remove outdated versions from the cellar.
#brew cleanup

# Install necessary npm packages
#npm install -g hexo hexo-cli

# Install simiki. for more information please refer to: http://simiki.org
#pip install -U simiki fabric Pygments

# Install rust through rustup: https://www.rustup.rs/
curl https://sh.rustup.rs -sSf | sh
