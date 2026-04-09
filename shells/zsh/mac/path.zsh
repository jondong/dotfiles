#==============================================================================
# MacOS 特定路径设置 - MacOS Specific PATH Configuration
#==============================================================================

# Only run on MacOS
if [[ "$PLATFORM" != "Darwin" ]]; then
    return 0
fi

# Setup MacOS-specific paths
setup_macos_paths() {
    # Homebrew paths for additional binaries (openssl, llvm, etc.)
    # Note: Main /opt/homebrew/bin/sbin are added at the end of zshrc to ensure correct PATH ordering
    if command -v brew >/dev/null 2>&1; then
        local brew_prefix=$(brew --prefix)
        # Add optional Homebrew paths that aren't in the main prefix
        if [[ -d "$brew_prefix/opt/openssl@3/bin" ]]; then
            export PATH="$brew_prefix/opt/openssl@3/bin:$PATH"
        fi
        if [[ -d "$brew_prefix/opt/llvm/bin" ]]; then
            export PATH="$brew_prefix/opt/llvm/bin:$PATH"
        fi
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

    # Antigravity paths
    prepend_path_if_exists "$HOME/.antigravity/antigravity/bin"
}

# Run MacOS-specific path setup
setup_macos_paths