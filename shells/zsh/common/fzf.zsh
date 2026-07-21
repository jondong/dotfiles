#==============================================================================
# FZF configuration
#==============================================================================

# fzf shell integration is only useful in interactive shells. The binary is
# installed independently by the platform package scripts.
if [[ $- != *i* ]] || ! command -v fzf >/dev/null 2>&1; then
    return 0
fi

fzf_fd_options="--hidden --follow --exclude .git --exclude node_modules"
fzf_copy_command=""

case "${PLATFORM:-$(uname)}" in
    Darwin)
        command -v pbcopy >/dev/null 2>&1 && fzf_copy_command="pbcopy"
        ;;
    Linux)
        if command -v xclip >/dev/null 2>&1; then
            fzf_copy_command="xclip -selection clipboard"
        elif command -v xsel >/dev/null 2>&1; then
            fzf_copy_command="xsel --clipboard --input"
        fi
        ;;
esac

export FZF_DEFAULT_OPTS="
    --no-mouse
    --height=50%
    --layout=reverse
    --info=inline
    --select-1
    --bind='ctrl-d:half-page-down,ctrl-u:half-page-up'
"

export FZF_DEFAULT_COMMAND="git ls-files --cached --others --exclude-standard 2>/dev/null || fd --type f --type l ${fzf_fd_options}"
export FZF_CTRL_T_COMMAND="fd ${fzf_fd_options}"
export FZF_ALT_C_COMMAND="fd --type d ${fzf_fd_options}"

fzf_file_bindings="f2:toggle-preview,f3:execute(bat --style=numbers --color=always -- {} || less -f {})"
if [[ -n "$fzf_copy_command" ]]; then
    fzf_file_bindings+=",ctrl-y:execute-silent(printf '%s\\n' {+} | ${fzf_copy_command})"
fi

export FZF_CTRL_T_OPTS="
    --multi
    --preview='if [[ -d {} ]]; then tree -C {} | head -200; elif file --mime {} | grep -q binary; then file --brief {}; else bat --style=numbers --color=always -- {} 2>/dev/null || sed -n \"1,300p\" < {}; fi'
    --preview-window='right:hidden:wrap'
    --bind='${fzf_file_bindings}'
"

export FZF_ALT_C_OPTS="
    --preview='tree -C {} | head -200'
    --preview-window='right:hidden:wrap'
    --bind='f2:toggle-preview'
"

if [[ -n "$fzf_copy_command" ]]; then
    export FZF_CTRL_R_OPTS="--bind='ctrl-y:execute-silent(echo -n {2..} | ${fzf_copy_command})+abort'"
else
    export FZF_CTRL_R_OPTS=""
fi

# The integration script is embedded in modern fzf releases, keeping it in
# sync with the installed binary and avoiding generated ~/.fzf.zsh files.
source <(fzf --zsh)

# Override the integration's default walker with fd so .gitignore and the
# repository's shared exclusion rules behave consistently on every platform.
_fzf_compgen_path() {
    command fd --hidden --follow --exclude .git --exclude node_modules . "$1"
}

_fzf_compgen_dir() {
    command fd --type d --hidden --follow --exclude .git --exclude node_modules . "$1"
}

unset fzf_fd_options fzf_copy_command fzf_file_bindings
