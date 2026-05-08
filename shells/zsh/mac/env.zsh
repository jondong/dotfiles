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
# Note: PATH manipulation is now handled by mac/path.zsh to ensure correct ordering
if command -v brew >/dev/null 2>&1; then
    HOMEBREW_PREFIX=$(brew --prefix)
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

# MacOS-specific aliases
alias ipi='ipconfig getifaddr en0'
