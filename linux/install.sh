#!/bin/bash
# Install necessary softwares for Linux here.
sudo apt-get -y install aptitude

sudo aptitude -y install vim git git-extras git-completion ruby-dev rubygems tmux terminator source-highlight mosh autojump xclip nodejs npm privoxy ssh tree expect cgdb gvim valgrind clang shellcheck tmux openssl gnutils gnutls-bin global cscope exuberant-ctags libgnome-keyring-dev unzip curl tar python-setuptools python-pip zsh

sudo gem install ghi

# Install gitup from git-repo-updater.
echo "Installing gitup..."
git clone https://github.com/earwig/git-repo-updater.git /tmp/git-repo-updater
pushd /tmp/git-repo-updater
python setup.py install --user
popd

node_module_path=$(npm config get prefix)
if [ $node_module_path = '/usr/local' ]; then
  sudo mkdir $node_module_path/lib/node_modules
  sudo chown -R $(whoami) $node_module_path/{lib/node_modules,bin,share}
fi

npm install -g coffee-script

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
