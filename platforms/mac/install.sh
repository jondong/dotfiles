#!/usr/bin/env bash
#Install necessary softwares for Mac here.

# Make sure we are using the lates homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade --all

# base system tools
brew install bash zsh bash-completion2 bash-git-prompt zsh-competions reattach-to-user-namespace antigen findutils

# utilities
brew install nvim tmux zellij ssh-copy-id wget tree autojump ag btop bat mas z fd fzf ack prettyping mosh ncdu tldr trash rsync ripgrep highlight ca-certificates cat ccat duf the_silver_searcher

# fonts
brew install freetype font-anonymice-nerd-font font-jetbrains-mono-nerd-font

# for development
brew install pyenv pyenv-virtualenv jenv nvm rustup cmake shellcheck xctool gitup mobile-shell ghi yarn icdiff diff-so-fancy tokei openjdk openssl openssh krb5 imagemagick ios-deploy ideviceinstalle cocoapods gh ghi gibo git-extras git-flow git-lfs git-open git-quick-stats sqlite

# GUI quicklook tools
brwe install provisionql qlimagesize qlmarkdown qlprettypatch qlvideo quicklook-json webpquicklook fliqlo

# casks
brew install 1password-cli
brew install --cask cheatsheet dash eudic muzzle the-unarchiver visual-studio-code warp

# To install useful key bindings and fuzzy completion
$(brew --prefix)/opt/fzf/install

# setup pyenv
local pyenv_versions="2.7.18 3.10.15"
pyenv install $pyenv_versions
pyenv global $pyenv_versions

diff-so-fancy --set-defaults

# Remove outdated versions from the cellar.
brew cleanup

