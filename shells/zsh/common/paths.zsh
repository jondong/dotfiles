#==============================================================================
# PATH 和基本环境设置 - PATH and Basic Environment Setup
#==============================================================================

setup_common_paths() {
    prepend_path_if_exists "$HOME/.local/bin"
    prepend_path_if_exists "$HOME/bin"
    prepend_path_if_exists "$DOTFILES_ROOT/bin"

    export ONEDRIVE_PATH="$HOME/OneDrive"
    prepend_path_if_exists "$ONEDRIVE_PATH/bin"

    append_path_if_exists "$HOME/go/bin"
    prepend_path_if_exists "$HOME/.cargo/bin"

    append_path_if_exists "$HOME/.rvm/bin"
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
}

setup_common_paths

[[ -r ~/.local/bin/env ]] && . "$HOME/.local/bin/env"
