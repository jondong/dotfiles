#==============================================================================
# MacOS 特定路径设置 - MacOS Specific PATH Configuration
#==============================================================================

# Only run on MacOS
if [[ "$PLATFORM" != "Darwin" ]]; then
    return 0
fi

# Setup MacOS-specific paths
setup_macos_paths() {
    # Homebrew paths (Apple Silicon: /opt/homebrew, Intel: /usr/local)
    # Must be added early, before other PATH manipulations
    # NOTE: Can't use `command -v brew` here because /opt/homebrew/bin may not be in PATH yet.
    # Check for the brew binary directly at known locations instead.
    local brew_prefix=""
    if [[ -f /opt/homebrew/bin/brew ]]; then
        brew_prefix="/opt/homebrew"
    elif [[ -f /usr/local/bin/brew ]]; then
        brew_prefix="/usr/local"
    fi

    if [[ -n "$brew_prefix" ]]; then
        prepend_path_if_exists "$brew_prefix/bin"
        prepend_path_if_exists "$brew_prefix/sbin"
        # Add optional Homebrew paths for specific formulae
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

    # Antigravity paths
    prepend_path_if_exists "$HOME/.antigravity/antigravity/bin"
}

# Run MacOS-specific path setup
setup_macos_paths