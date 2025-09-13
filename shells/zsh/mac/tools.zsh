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

    # NVM setup - Node Version Manager
    setup_nvm() {
        # Check common NVM locations
        local nvm_dirs=(
            "$HOME/.nvm"
            "/opt/homebrew/opt/nvm"
            "/usr/local/opt/nvm"
        )

        for nvm_dir in "${nvm_dirs[@]}"; do
            if [[ -s "$nvm_dir/nvm.sh" ]]; then
                export NVM_DIR="$nvm_dir"
                source "$NVM_DIR/nvm.sh"
                break
            fi
        done
    }

    # Initialize NVM
    setup_nvm

    # Quick Look server (if available)
    if command -v qlmanage >/dev/null 2>&1; then
        alias ql='qlmanage -p 2>/dev/null'
    fi

    # MacOS clipboard integration
    if command -v pbcopy >/dev/null 2>&1 && command -v pbpaste >/dev/null 2>&1; then
        alias pbc='pbcopy'
        alias pbp='pbpaste'
        # Add FZF copy binding if FZF is available
        if command -v fzf >/dev/null 2>&1; then
            export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --bind='ctrl-y:execute-silent(echo {+} | pbcopy)'"
        fi
    fi

    # Finder integration
    if command -v open >/dev/null 2>&1; then
        alias finder='open -a Finder'
        alias show='open -R'
    fi
}

# Run MacOS-specific tool setup
setup_macos_tools