#==============================================================================
# PATH 和基本环境设置 - PATH and Basic Environment Setup
#==============================================================================

# Setup platform detection
setup_platform

# Basic environment variables
export LC_ALL=en_US.UTF-8
export EDITOR=nvim
export DOTFILES_ROOT="$HOME/.dotfiles"
export HISTIGNORE='pwd:exit:fg:bg:top:clear:history:ls:uptime:df:ll:la:gst'
export HISTCONTROL=ignoredups
export HISTSIZE=10000
export PROJECTS=$HOME/projects

# Load Rust environment if available
[[ -s "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Common PATH modifications
setup_common_paths() {
    # set PATH so it includes user's private bin if it exists
    prepend_path_if_exists "$HOME/.local/bin"
    prepend_path_if_exists "$HOME/bin"

    # Add dotfiles scripts path
    prepend_path_if_exists "$DOTFILES_ROOT/bin"

    # Scripts in OneDrive
    export ONEDRIVE_PATH="$HOME/OneDrive"
    prepend_path_if_exists "$ONEDRIVE_PATH/bin"

    # Go path
    append_path_if_exists "$HOME/go/bin"

    # rustup path
    prepend_path_if_exists "$HOME/.cargo/bin"

    # yarn path
    if command_exists yarn; then
        export PATH=$PATH:"$(yarn global bin)"
    fi

    # RVM
    append_path_if_exists "$HOME/.rvm/bin"
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

    # pyenv
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
}

# Run common path setup
setup_common_paths

# Load proxy settings
[[ -f ~/.proxyrc ]] && source ~/.proxyrc

# Load local configs only if they exist and are readable
[[ -r ~/.local/bin/env ]] && . "$HOME/.local/bin/env"
