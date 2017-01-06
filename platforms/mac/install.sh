#!/usr/bin/env bash
#Install necessary softwares for Mac here.

# Check if homebrew get installed.
if [ ! $(command_exists brew) ]; then
  echo "  Installing homebrew for you..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Make sure we are using the lates homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade --all

# Install homebrew packages
brew install coreutils git git-lfs git-extras
sudo ln -s /usr/local/bin/gsha256sum /usr/local/bin/sha256sum

# Install some other useful utilities like `sponge`.
brew install moreutils findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names

# Install Bash 4.
# Note: don’t forget to add `/usr/local/bin/bash` and `/usr/local/bin/zsh`
# to `/etc/shells` before running `chsh`.
brew tap homebrew/versions
brew install vim --with-client-server --override-system-vi
brew install wget --with-iri
brew install homebrew/dupes/grep homebrew/dupes/openssh
brew install caskroom/cask/brew-cask

brew install bash zsh tmux bash-completion2 bash-git-prompt macvim cmake shellcheck xctool ccache chisel appledoc dark-mode ssh-copy-id tree npm autojump reattach-to-user-namespace gitup ag htop ccat mobile-shell global ctags ghi yarn icu4c

gem install teamocil gollum
mkdir -p ~/.teamocil

# Install hexo for personal blog
npm install -g hexo hexo-cli

# Installations using cask
brew cask install easysimbl oclint

# Install simiki. for more information please refer to: http://simiki.org
pip install simiki fabric

# Remove outdated versions from the cellar.
brew cleanup
