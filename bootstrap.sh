#!/usr/bin/env bash

#DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
DOTFILES_ROOT="$HOME/.dotfiles"

info () {
  printf "  [ \033[00;34m..\033[0m ] $1"
}

user () {
  printf "\r  [ \033[0;33m?\033[0m ] $1 "
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

link_file () {
  local src=$1 dst=$2

  local overwrite= backup= skip=
  local action=

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]
  then

    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
    then

      local currentSrc="$(readlink $dst)"

      if [ "$currentSrc" == "$src" ]
      then

        skip=true;

      else

        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac

      fi

    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]
    then
      rm -rf "$dst"
      success "removed $dst"
    fi

    if [ "$backup" == "true" ]
    then
      mv "$dst" "${dst}.backup"
      success "moved $dst to ${dst}.backup"
    fi

    if [ "$skip" == "true" ]
    then
      success "skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]  # "false" or empty
  then
    ln -s "$1" "$2"
    success "linked $1 to $2"
  fi
}

install_dotfiles () {
  info 'installing dotfiles'

  local overwrite_all=false backup_all=false skip_all=false

  local files_to_link=""
  if [ "$(uname)" = "Darwin" ]; then
    files_to_link=$(find -H "$DOTFILES_ROOT" -maxdepth 2 -name "*.symlink" -o -name "*.macsymlink")
  elif [ "$(uname)" = "Linux" ]; then
    files_to_link=$(find -H "$DOTFILES_ROOT" -maxdepth 2 -name "*.symlink" -o -name "*.linuxsymlink")
  elif [ "$(uname -o)" = "Cygwin" ]; then
    files_to_link=$(find -H "$DOTFILES_ROOT" -maxdepth 2 -name "*.symlink" -o -name "*.winsymlink")
  fi

  for src in $files_to_link
  do
    dst="$HOME/.$(basename "${src%.*}")"
    link_file "$src" "$dst"
  done
}

install_vim_config () {
    info 'installing vim configurations...'
    sh <(curl https://j.mp/spf13-vim3 -L)
}

update_vim_config () {
    info 'updating vim configurations...'
    sh <(curl https://j.mp/spf13-vim3 -L -o -)
}

TMUX_PLUGIN_MANAGER_ROOT="$HOME/.tmux/plugins/tpm"
install_tmux_plugin_manager () {
  mkdir -p "$TMUX_PLUGIN_MANAGER_ROOT"
  git clone https://github.com/tmux-plugins/tpm "$TMUX_PLUGIN_MANAGER_ROOT"
}

update_tmux_plugin_manager () {
  pushd "$TMUX_PLUGIN_MANAGER_ROOT" > /dev/null
  git pull --rebase origin master
  popd > /dev/null
}

if [ ! -d "$DOTFILES_ROOT" ]; then
  info "installing dotfiles for the first time."
  git clone https://github.com/jondong/dotfiles.git "$DOTFILES_ROOT"
  pushd "$DOTFILES_ROOT" > /dev/null

  install_dotfiles
else
  info "already installed dotfiles, updating..."
  pushd "$DOTFILES_ROOT" > /dev/null
  git pull --rebase origin master
fi

popd > /dev/null

if [ ! -d "$HOME/.spf13-vim-3" ]; then
    install_vim_config
else
    update_vim_config
fi

if [ ! -d "$TMUX_PLUGIN_MANAGER_ROOT" ]; then
    install_tmux_plugin_manager
else
    update_tmux_plugin_manager
fi

tmux source $HOME/.tmux.conf

# Create logs directory.
if [ ! -d "$HOME/logs" ]; then
    mkdir -p $HOME/logs
fi
