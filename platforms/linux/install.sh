#!/usr/bin/env bash

read -e -p "Install Linux for production deployment? (Which means do not install packages for devs) [y/N] " -n 1
is_production=${REPLY:=n}

packages=(vim git tmux autojump xclip ssh tree shellcheck openssl unzip curl tar zsh exfat-utils exfat-fuse nodejs yarn cmake)
if [ ${is_production,,} = 'n' ]; then
  echo "Install packages for development machine."
  packages=("${packages[@]}" git-extras terminator mosh ruby ruby-dev source-highlight expect cgdb valgrind clang global cscope exuberant-ctags python-setuptools python-pip cargo net-tools ncdu)
else
  echo "Install packages for production machine."
fi

# Setup nodejs v11 deb source
curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -

# Setup yarn deb source
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Install necessary softwares for Linux here. Also removed unnecessary apps.
sudo apt -y remove libreoffice-core libreoffice-base-core libreoffice-common
sudo apt -y autoremove
sudo apt -y update
sudo apt -y upgrade
sudo apt -y install "${packages[@]}"

# Avoid zsh-compinit-insecure-directories issues.
# refers to: http://stackoverflow.com/questions/13762280/zsh-compinit-insecure-directories for more details.
pushd /usr/local/share/zsh
sudo chmod -R 755 ./site-functions
popd

if [ ${is_production,,} = 'n' ]; then
  # Install exa with cargo
  cargo install exa

  # setup crontab
  if [ -f "$HOME/.crontab" ]; then
    crontab -u $(whoami) "$HOME/.crontab"
  fi
fi
