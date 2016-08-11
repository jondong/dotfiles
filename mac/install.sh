#!/bin/bash
#Install necessary softwares for Mac here.

# Check if homebrew get installed.
if [ ! $(check_existence brew) ]; then
  echo "  Installing homebrew for you..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Make sure we are using the lates homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade --all

# Install homebrew packages
brew install coreutils
sudo ln -s /usr/local/bin/gsha256sum /usr/local/bin/sha256sum

# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names

# Install Bash 4.
# Note: don’t forget to add `/usr/local/bin/bash` and `/usr/local/bin/zsh`
# to `/etc/shells` before running `chsh`.
brew install bash zsh
brew tap homebrew/versions
brew install bash-completion2

brew install git git-lfs git-extras
brew install bash-git-prompt

brew install vim --override-system-vi
brew install macvim
brew install caskroom/cask/brew-cask
brew install cmake
brew install neovim
brew install wget --with-iri
brew install shellcheck
brew install xctool
brew install ccache
brew install chisel
brew install appledoc
brew install dark-mode
brew install ssh-copy-id
brew install tree

brew install npm
brew install tmux --HEAD
brew install autojump
brew install reattach-to-user-namespace
brew install gitup
brew install ag htop ccat
brew install ghi
brew install mobile-shell
brew install mackup
brew install global ctags

brew install homebrew/dupes/grep
brew install homebrew/dupes/openssh

brew install nvm
mkdir ~/.nvm
cp $(brew --prefix nvm)/nvm-exec ~/.nvm/

# Installations using cask
brew cask install easysimbl
brew cask install oclint

# Remove outdated versions from the cellar.
brew cleanup
