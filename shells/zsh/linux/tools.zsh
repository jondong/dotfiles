#==============================================================================
# Linux 特定工具配置 - Linux Specific Tool Configuration
#==============================================================================

# Only run on Linux
if [[ "$PLATFORM" != "Linux" ]]; then
    return 0
fi

# Android SDK setup for Linux
setup_android_sdk() {
    local android_sdk="$HOME/Android/Sdk"
    local android_ndk="$HOME/Android/Sdk/ndk/current"

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

# Setup Linux-specific tools
setup_linux_tools() {
    # Android SDK
    setup_android_sdk

    # Linux clipboard integration (if available)
    if command -v xclip >/dev/null 2>&1; then
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
    elif command -v xsel >/dev/null 2>&1; then
        alias pbcopy='xsel --clipboard --input'
        alias pbpaste='xsel --clipboard --output'
    fi

    # File manager integration
    if command -v xdg-open >/dev/null 2>&1; then
        alias open='xdg-open'
    fi

    # System info aliases for Linux
    alias meminfo='free -m -l -t'
    alias cpuinfo='lscpu'
    alias diskusage='df -h'
    alias ports='netstat -tulanp'

    # Process management
    alias psgrep='ps aux | grep'
    alias killport='fuser -k'

    # Package manager helpers
    if command -v apt >/dev/null 2>&1; then
        alias aptupdate='sudo apt update && sudo apt upgrade'
        alias aptsearch='apt search'
        alias aptinstall='sudo apt install'
    elif command -v yum >/dev/null 2>&1; then
        alias yumupdate='sudo yum update'
        alias yumsearch='yum search'
        alias yuminstall='sudo yum install'
    elif command -v pacman >/dev/null 2>&1; then
        alias pacupdate='sudo pacman -Syu'
        alias pacsearch='pacman -Ss'
        alias pacinstall='sudo pacman -S'
    fi
}

# Run Linux-specific tool setup
setup_linux_tools