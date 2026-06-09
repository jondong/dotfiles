#==============================================================================
# 最终配置加载 - Final Configuration Loading
#==============================================================================

if [[ -d "$HOME/.sdkman" ]]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

if command -v pyenv >/dev/null 2>&1; then
    export PYENV_INIT=true
    eval "$(pyenv init - zsh --no-rehash)"
fi

export RNOH_C_API_ARCH="1"

PROMPT='%n@%m:%~%# '

if [[ -t 1 ]] && [[ ${TERM:-dumb} != "dumb" ]]; then
    PROMPT='%F{cyan}%n@%m%f:%F{yellow}%~%f%# '
fi
