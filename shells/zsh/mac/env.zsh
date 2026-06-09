#==============================================================================
# MacOS 特定环境变量 - MacOS Specific Environment Variables
#==============================================================================

export MACOS_SPECIFIC_PATHS_LOADED=1

if [[ "$PLATFORM" != "Darwin" ]]; then
    return 0
fi

if [[ -f /opt/homebrew/bin/brew ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
elif [[ -f /usr/local/bin/brew ]]; then
    HOMEBREW_PREFIX="/usr/local"
fi
if [[ -n "$HOMEBREW_PREFIX" ]]; then
    export HOMEBREW_PREFIX
fi

export ANDROID_SDK=$HOME/Library/Android/sdk
export ANDROID_NDK=$HOME/Library/Android/sdk/ndk/current

export PNPM_HOME="$HOME/Library/pnpm"

export NVM_DIR="$HOME/.nvm"

export SDKROOT="$(xcrun --sdk macosx --show-sdk-path 2>/dev/null)"

alias ipi='ipconfig getifaddr en0'
