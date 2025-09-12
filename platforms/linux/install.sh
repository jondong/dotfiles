#!/usr/bin/env bash

read -e -p "Install Linux for production deployment? (Which means do not install packages for devs) [y/N] " -n 1
is_production=${REPLY:=n}

packages=(neovim git autojump xclip xsel ssh tree openssl unzip curl tar zsh exfat-fuse eza bat fd-find tree prettyping pipx findutils ack duf fcitx5 fcitx5-rime fcitx5-configtool rime-data-double-pinyin)
if [ ${is_production,,} = 'n' ]; then
  echo "Install packages for development machine."
  packages=("${packages[@]}" git-extras git-lfs git-flow gh shellcheck cmake alacritty mosh ruby ruby-dev source-highlight expect cgdb valgrind clang global cscope exuberant-ctags net-tools ncdu gdu ripgrep gnome-tweak-tool rustup btop highlight fonts-jetbrains-mono fonts-firacode fonts-hack rbenv ruby-build direnv docker-compose icdiff)
else
  echo "Install packages for production machine."
fi

# Install necessary softwares for Linux here. Also removed unnecessary apps.
sudo apt -y remove libreoffice-core libreoffice-base-core libreoffice-common
sudo apt -y autoremove
sudo apt -y update
sudo apt -y upgrade
sudo apt -y install "${packages[@]}"

# Install apps with snap
snap install --classic zellij
snap install diff-so-fancy

# Install apps with pipx
pipx install gitup uv poetry

# Install rust environment and rust apps
rustup default stable
cargo install tokei

# Install fzf
[[ ! -d ~/.fzf ]] && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

# Install jenv
[[ ! -d ~/.jenv ]] && git clone https://github.com/jenv/jenv.git ~/.jenv

# Install nvm
[[ ! -d ~/.nvm ]] && git clone https://github.com/nvm-sh/nvm.git ~/.nvm

# Install lazydocker
[[ ! -f ~/.local/bin/lazydocker ]] && curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

if [ ${is_production,,} = 'n' ]; then
  # setup crontab
  if [ -f "$HOME/.crontab" ]; then
    crontab -u $(whoami) "$HOME/.crontab"
  fi
fi
