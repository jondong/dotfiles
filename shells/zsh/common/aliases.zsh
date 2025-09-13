#==============================================================================
# Common Aliases - 通用别名配置
#==============================================================================

# Basic command improvements
alias ping='prettyping --nolegend'
alias top='btop'
alias du='ncdu -rr -x --exclude .git --exclude node_modules'
alias help='tldr'
alias cp='cp -i'
alias wget='wget -c '
alias vim='nvim'
alias www='python -m http.server'
alias lzd='lazydocker'
alias bazel='bazelisk'
alias npm-exec='PATH=$(npm bin):$PATH'

# LS aliases
alias ll='ls -l'
alias la='ls -lAh'
alias l='ls -lah'

# IP related (common part, platform specific in respective dirs)
alias ipe='curl ipinfo.io/ip'