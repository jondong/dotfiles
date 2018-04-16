#!/usr/bin/env bash
#Install necessary softwares for Mac here.

gem install teamocil pygments.rb
mkdir -p ~/.teamocil

# Check if homebrew get installed.
if [ ! $(command_exists brew) ]; then
  echo "  Installing homebrew for you..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Make sure we are using the lates homebrew.
brew update

# Install homebrew packages
brew install coreutils git git-lfs git-extras cocoapods
sudo ln -s /usr/local/bin/gsha256sum /usr/local/bin/sha256sum

# Install some other useful utilities like `sponge`.
brew install moreutils findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names

# Install Bash 4.
# Note: don’t forget to add `/usr/local/bin/bash` and `/usr/local/bin/zsh`
# to `/etc/shells` before running `chsh`.
brew tap homebrew/versions
#brew tap oclint/formulae
brew install caskroom/cask/brew-cask
brew install wget --with-iri
brew install homebrew/dupes/grep homebrew/dupes/openssh
brew cask install xquartz
brew install vim --with-client-server --override-system-vi --with-python@2

brew install bash zsh tmux bash-completion2 bash-git-prompt cmake shellcheck xctool ccache chisel appledoc dark-mode ssh-copy-id tree npm autojump reattach-to-user-namespace gitup ag htop ccat mobile-shell global ctags ghi yarn aria2 mas gradle

# Upgrade any already-installed formulae.
brew upgrade --all

# Remove outdated versions from the cellar.
brew cleanup

# Install necessary npm packages
npm install -g hexo hexo-cli

# Install simiki. for more information please refer to: http://simiki.org
pip install simiki fabric

# Install rust through rustup: https://www.rustup.rs/
curl https://sh.rustup.rs -sSf | sh
