#!/bin/bash
# Install necessary softwares for Linux here.

# Install gitup from git-repo-updater.
echo "Installing gitup..."
git clone https://github.com/earwig/git-repo-updater.git /tmp/git-repo-updater
pushd /tmp/git-repo-updater
python setup.py install --user
popd

sudo gem install ghi
sodo apt-get install mosh
sudo apt-get install xclip # or xsel. this is for tmux-yank plugin.
