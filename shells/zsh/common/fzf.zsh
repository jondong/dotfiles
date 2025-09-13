#==============================================================================
# FZF 配置 - FZF Configuration
#==============================================================================

# Only load FZF if installed and in interactive mode
if [[ $- == *i* ]] && [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh

    FD_OPTIONS="--hidden --follow --exclude .git --exclude node_modules"
    export FZF_DEFAULT_OPTS="--no-mouse --height 50% -1 --reverse --multi --inline-info --preview='[[ \$(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || cat {}) 2> /dev/null | head -300' --preview-window='right:hidden:wrap' --bind='f3:execute(bat --style=numbers {} || less -f {}),f2:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-a:select-all+accept,ctrl-y:execute-silent(echo {+} | pbcopy),ctrl-x:execute(rm -i {+})+abort'"
    export FZF_DEFAULT_COMMAND="git ls-files --cached --others --exclude-standard || fd --type f --type l $FD_OPTIONS"
    export FZF_CTRL_T_COMMAND="fd $FD_OPTIONS"
    export FZF_ALT_C_COMMAND="fd --type d $FD_OPTIONS"
fi

# FZF completion functions - only define if FZF is available
if command -v fzf >/dev/null 2>&1; then
    _fzf_compgen_path() {
        command fd --hidden --follow --exclude .git --exclude node_modules . "$1"
    }

    _fzf_compgen_dir() {
        command fd --type d --hidden --follow --exclude .git --exclude node_modules . "$1"
    }
fi