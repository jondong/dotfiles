# Append necessary path to PATH.

source $DOTFILES/profile

# bindkey with Emacs style. This is for tmux-yank plugin.
bindkey -e

alias npm-exec='PATH=$(npm bin):$PATH'
