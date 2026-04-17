#==============================================================================
# 最终配置加载 - Final Configuration Loading
#==============================================================================

# SDKMAN - load only if directory exists
if [[ -d "$HOME/.sdkman" ]]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# pyenv setup - 仅在 pyenv 存在时才初始化
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init - zsh)"
fi

# LM Studio
[[ -d "$HOME/.lmstudio/bin" ]] && export PATH="$PATH:$HOME/.lmstudio/bin"

# HarmonyOS configuration
export RNOH_C_API_ARCH="1"

# Final prompt setup - set at the very end to override any other configurations
# Use basic prompt that works in all environments
PROMPT='%n@%m:%~%# '

# Try to add colors if terminal supports it
if [[ -t 1 ]] && [[ ${TERM:-dumb} != "dumb" ]]; then
    PROMPT='%F{cyan}%n@%m%f:%F{yellow}%~%f%# '
fi

# Optional: Print profiling results
# zprof
