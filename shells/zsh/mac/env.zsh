#==============================================================================
# MacOS 特定环境变量 - MacOS Specific Environment Variables
#==============================================================================

# MacOS-specific environment setup
export MACOS_SPECIFIC_PATHS_LOADED=1

# Check if we're on MacOS
if [[ "$PLATFORM" != "Darwin" ]]; then
    return 0
fi

# Add Homebrew paths if available
# NOTE: Can't use `command -v brew` because /opt/homebrew/bin may not be in PATH yet.
if [[ -f /opt/homebrew/bin/brew ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
elif [[ -f /usr/local/bin/brew ]]; then
    HOMEBREW_PREFIX="/usr/local"
fi
if [[ -n "$HOMEBREW_PREFIX" ]]; then
    export HOMEBREW_PREFIX
fi

# MacOS-specific Android SDK paths
export ANDROID_SDK=$HOME/Library/Android/sdk
export ANDROID_NDK=$HOME/Library/Android/sdk/ndk/current

# MacOS-specific PNPM path
export PNPM_HOME="$HOME/Library/pnpm"

# NVM setup for MacOS via Homebrew - NOW LAZY LOADED in mac/tools.zsh
# Do not source nvm.sh here - it causes slow shell startup
# NVM_DIR is exported so tools.zsh can use it for lazy loading
export NVM_DIR="$HOME/.nvm"
if [[ -n "$HOMEBREW_PREFIX" ]]; then
    [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
fi

# MacOS-specific aliases
alias ipi='ipconfig getifaddr en0'
