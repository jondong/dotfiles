#==============================================================================
# Linux 特定环境变量 - Linux Specific Environment Variables
#==============================================================================

# Linux-specific environment setup
export LINUX_SPECIFIC_PATHS_LOADED=1

# Check if we're on Linux
if [[ "$PLATFORM" != "Linux" ]]; then
    return 0
fi

# Clean up brew paths if brew is not installed (Linux-specific without Homebrew)
if ! command -v brew >/dev/null 2>&1; then
    export PATH=$(echo "$PATH" | tr ':' '\n' | grep -vE '(linuxbrew|brew)' | tr '\n' ':' | sed 's/:$//')
fi

# Linux-specific Android SDK paths
export ANDROID_SDK=$HOME/Android/Sdk
export ANDROID_NDK=$HOME/Android/Sdk/ndk/current

# Linux-specific PNPM path
export PNPM_HOME="$HOME/.local/share/pnpm"

# Linux-specific PATH additions
[[ -d "$HOME/.local/bin" ]] && export PATH="$PATH:$HOME/.local/bin"
[[ -d "/usr/local/go/bin" ]] && export PATH="$PATH:/usr/local/go/bin"

# NVM setup for Linux
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"