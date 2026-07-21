#==============================================================================
# MacOS 特定工具配置 - MacOS Specific Tool Configuration
#==============================================================================

# Only run on MacOS
if [[ "$PLATFORM" != "Darwin" ]]; then
    return 0
fi

# Android SDK setup for MacOS
setup_android_sdk() {
    local android_sdk="$HOME/Library/Android/sdk"
    local android_ndk="$HOME/Library/Android/sdk/ndk/current"

    if [[ -d "$android_sdk" ]]; then
        export ANDROID_SDK="$android_sdk"
        export ANDROID_NDK="$android_ndk"
        export ANDROID_HOME="$android_sdk"
        export ANDROID_SDK_ROOT="$android_sdk"

        # Add Android tools to PATH
        append_path_if_exists "$android_sdk/tools"
        append_path_if_exists "$android_sdk/tools/bin"
        append_path_if_exists "$android_sdk/platform-tools"
        append_path_if_exists "$android_sdk/cmdline-tools/latest/bin"

        if [[ -d "$android_ndk" ]]; then
            export ANDROID_NDK_HOME="$android_ndk"
            append_path_if_exists "$android_ndk"
        fi
    fi
}

# Setup MacOS-specific tools
setup_macos_tools() {
    # Android SDK
    setup_android_sdk

    # NVM setup - Node Version Manager (lazy loaded)
    setup_nvm() {
        # Check common NVM locations
        local nvm_dir=""
        for dir in "$HOME/.nvm" "/opt/homebrew/opt/nvm" "/usr/local/opt/nvm"; do
            if [[ -s "$dir/nvm.sh" ]]; then
                nvm_dir="$dir"
                break
            fi
        done

        if [[ -n "$nvm_dir" ]]; then
            export NVM_DIR="$nvm_dir"
            # Lazy load nvm - source nvm.sh on first invocation and auto-use default version
            lazy_load nvm "source \"$NVM_DIR/nvm.sh\" && nvm use default >/dev/null 2>&1"
        fi
    }

    # Setup NVM (lazy loading)
    setup_nvm

    # Quick Look server (if available)
    if command -v qlmanage >/dev/null 2>&1; then
        alias ql='qlmanage -p 2>/dev/null'
    fi

    # MacOS clipboard integration
    if command -v pbcopy >/dev/null 2>&1 && command -v pbpaste >/dev/null 2>&1; then
        alias pbc='pbcopy'
        alias pbp='pbpaste'
    fi

    # Finder integration
    if command -v open >/dev/null 2>&1; then
        alias finder='open -a Finder'
        alias show='open -R'
    fi
}

# Run MacOS-specific tool setup
setup_macos_tools
