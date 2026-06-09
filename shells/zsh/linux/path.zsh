#==============================================================================
# Linux 特定路径设置 - Linux Specific PATH Configuration
#==============================================================================

if [[ "$PLATFORM" != "Linux" ]]; then
    return 0
fi

setup_linux_paths() {
    prepend_path_if_exists "/usr/local/bin"
    prepend_path_if_exists "/usr/local/sbin"

    append_path_if_exists "/snap/bin"
    append_path_if_exists "/var/lib/flatpak/exports/bin"

    prepend_path_if_exists "$HOME/.local/bin"

    append_path_if_exists "/usr/local/go/bin"
    append_path_if_exists "$HOME/go/bin"

    append_path_if_exists "/opt/bin"
    append_path_if_exists "/opt/local/bin"

    append_path_if_exists "/usr/lib/node_modules/.bin"

    append_path_if_exists "$HOME/.local/bin"
    append_path_if_exists "$HOME/.gem/ruby/bin"
}

setup_linux_paths
