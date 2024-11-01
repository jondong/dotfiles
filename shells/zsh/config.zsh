if [ $PLATFORM = "Darwin" ]; then
  alias cat='bat --theme zenburn'
  alias rm='trash'
elif [ $PLATFORM = "Linux" ]; then
  local dist=$(lsb_release -is)
  if [[ "$dist" == "Ubuntu" ]]; then
    alias cat='batcat'
    alias fd='fdfind'
  elif [[ "$dist" == "openSUSE" ]]; then
    alias cat='bat'
  fi
fi
alias ping='prettyping --nolegend'
alias top='btop'
alias du='ncdu -rr -x --exclude .git --exclude node_modules'
alias help='tldr'
alias cp='cp -i'
alias ipe='curl ipinfo.io/ip'
alias ipi='ipconfig getifaddr en0'
alias vim='nvim'
alias www='python -m http.server'
alias wget='wget -c '
alias lzd='lazydocker'
alias bazel='bazelisk'
