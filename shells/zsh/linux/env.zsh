#==============================================================================
# Linux 特定环境变量 - Linux Specific Environment Variables
#==============================================================================

export LINUX_SPECIFIC_PATHS_LOADED=1

if [[ "$PLATFORM" != "Linux" ]]; then
    return 0
fi

if ! command -v brew >/dev/null 2>&1; then
    export PATH=$(echo "$PATH" | tr ':' '\n' | grep -vE '(linuxbrew|brew)' | tr '\n' ':' | sed 's/:$//')
fi

export ANDROID_SDK=$HOME/Android/Sdk
export ANDROID_NDK=$HOME/Android/Sdk/ndk/current

export PNPM_HOME="$HOME/.local/share/pnpm"

[[ -d "$HOME/.local/bin" ]] && export PATH="$PATH:$HOME/.local/bin"
[[ -d "/usr/local/go/bin" ]] && export PATH="$PATH:/usr/local/go/bin"
