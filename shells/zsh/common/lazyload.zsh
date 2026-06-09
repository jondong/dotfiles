#==============================================================================
# 开发环境 Lazy Loading 配置 - Development Environment Lazy Loading
#==============================================================================

terminal_app="${TERM_PROGRAM:-}"
if [[ "$terminal_app" == *iTerm* ]] && [[ -e "${HOME}/.iterm2_shell_integration.zsh" ]]; then
    source "${HOME}/.iterm2_shell_integration.zsh"
fi

if [[ -f /usr/share/autojump/autojump.sh ]]; then
    lazy_load autojump ". /usr/share/autojump/autojump.sh"
elif command -v brew >/dev/null 2>&1 && [[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]]; then
    lazy_load autojump ". $(brew --prefix)/etc/profile.d/autojump.sh"
fi

if command -v jenv >/dev/null 2>&1; then
    lazy_load jenv 'eval "$(jenv init -)"'
fi

if [[ -d "$HOME/.rbenv" ]] || command -v rbenv >/dev/null 2>&1; then
    lazy_load rbenv 'eval "$(rbenv init - zsh)"'
fi

if command -v direnv >/dev/null 2>&1; then
    lazy_load direnv 'eval "$(direnv hook zsh)"'
fi
