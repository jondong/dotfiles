#!/usr/bin/env bash

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
