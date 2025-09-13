#==============================================================================
# MacOS 特定路径设置 - MacOS Specific PATH Configuration
#==============================================================================

# Only run on MacOS
if [[ "$PLATFORM" != "Darwin" ]]; then
    return 0
fi

# Setup MacOS-specific paths
setup_macos_paths() {
    # Homebrew paths (if brew is installed)
    if command -v brew >/dev/null 2>&1; then
        local brew_prefix=$(brew --prefix)
        prepend_path_if_exists "$brew_prefix/bin"
        prepend_path_if_exists "$brew_prefix/sbin"
        prepend_path_if_exists "$brew_prefix/opt/openssl@3/bin"
        prepend_path_if_exists "$brew_prefix/opt/llvm/bin"
    fi

    # MacOS Applications paths
    append_path_if_exists "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    append_path_if_exists "/Applications/Xcode.app/Contents/Developer/usr/bin"

    # MacPorts (if installed)
    append_path_if_exists "/opt/local/bin"
    append_path_if_exists "/opt/local/sbin"

    # Common MacOS development tools
    append_path_if_exists "/usr/local/bin"
    append_path_if_exists "/usr/local/sbin"
}

# Run MacOS-specific path setup
setup_macos_paths