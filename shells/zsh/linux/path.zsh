#==============================================================================
# Linux 特定路径设置 - Linux Specific PATH Configuration
#==============================================================================

# Only run on Linux
if [[ "$PLATFORM" != "Linux" ]]; then
    return 0
fi

# Setup Linux-specific paths
setup_linux_paths() {
    # Standard Linux binary locations
    prepend_path_if_exists "/usr/local/bin"
    prepend_path_if_exists "/usr/local/sbin"

    # Snap packages (if available)
    append_path_if_exists "/snap/bin"

    # Flatpak (if available)
    append_path_if_exists "/var/lib/flatpak/exports/bin"

    # User-specific installations
    prepend_path_if_exists "$HOME/.local/bin"

    # Go installation paths
    append_path_if_exists "/usr/local/go/bin"
    append_path_if_exists "$HOME/go/bin"

    # Common development tool paths
    append_path_if_exists "/opt/bin"
    append_path_if_exists "/opt/local/bin"

    # Node.js via package manager
    append_path_if_exists "/usr/lib/node_modules/.bin"

    # Python user scripts
    if command -v python3 >/dev/null 2>&1; then
        local python_user_base=$(python3 -m site --user-base 2>/dev/null)
        if [[ -n "$python_user_base" ]]; then
            append_path_if_exists "$python_user_base/bin"
        fi
    fi

    # Ruby user gems
    if command -v gem >/dev/null 2>&1; then
        local gem_user_dir=$(gem env userdir 2>/dev/null)
        if [[ -n "$gem_user_dir" ]]; then
            append_path_if_exists "$gem_user_dir/bin"
        fi
    fi
}

# Run Linux-specific path setup
setup_linux_paths