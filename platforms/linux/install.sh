#!/bin/bash

read -e -p "Install Linux for production? [y/N] " -n 1
is_production=${REPLY:=n}

packages=(nodejs vim git tmux autojump xclip privoxy ssh tree vim-gtk3-py2 shellcheck openssl libgnome-keyring-dev unzip curl tar zsh)
if [ ${is_production,,} = 'n' ]; then
  echo "Install packages for development machine."
  packages=("${packages[@]}" aptitude git-extras terminator mosh ruby ruby-dev source-highlight expect cgdb valgrind clang global cscope exuberant-ctags python-setuptools python-pip)
else
  echo "Install packages for production machine."
fi

# Setup nodejs v6 deb source
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -

# Install necessary softwares for Linux here.
sudo apt -y autoremove
sudo apt -y upgrade
sudo apt -y install "${packages[@]}"

# Setup gnome keyring for git
pushd /usr/share/doc/git/contrib/credential/gnome-keyring
sudo make
popd
git config --global credential.helper /usr/share/doc/git/contrib/credential/gnome-keyring/git-credential-gnome-keyring

# Avoid zsh-compinit-insecure-directories issues.
# refers to: http://stackoverflow.com/questions/13762280/zsh-compinit-insecure-directories for more details.
pushd /usr/local/share/zsh
sudo chmod -R 755 ./site-functions
popd

if [ ${is_production,,} = 'n' ]; then
  sudo gem install ghi teamocil
  mkdir -p ~/.teamocil

  # Install gitup from git-repo-updater.
  echo "Installing gitup..."
  git clone https://github.com/earwig/git-repo-updater.git /tmp/git-repo-updater
  pushd /tmp/git-repo-updater
  python setup.py install --user
  popd

  sudo npm install -g coffee-script

  # setup crontab
  if [ -f "$HOME/.crontab" ]; then
    crontab -u $(whoami) "$HOME/.crontab"
  fi
fi
