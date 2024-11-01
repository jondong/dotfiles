if [ $PLATFORM != "Cygwin" ]; then
  # Use antigen to manage zsh resource.
  # `cd ~ && git clone https://github.com/zsh-users/antigen.git .antigen`
  # for more information refers to: https://github.com/zsh-users/antigen
  if [ ! -d "$HOME/.antigen" ]; then
    git clone https://github.com/zsh-users/antigen.git $HOME/.antigen
  fi
  source "$HOME/.antigen/antigen.zsh"

  # Load the oh-my-zsh's library.
  antigen use oh-my-zsh

  # Bundles from the default repo (robbyrussell's oh-my-zsh).
  antigen bundle git
  antigen bundle pip

  # Syntax highlighting bundle.
  antigen bundle zsh-users/zsh-autosuggestions
  antigen bundle zsh-users/zsh-completions
  antigen bundle zsh-users/zsh-syntax-highlighting
  antigen bundle paulirish/git-open

  # Load the theme.
  antigen theme romkatv/powerlevel10k
  POWERLEVEL9K_MODE="awesome-patched"

  # Tell antigen that you're done.
  antigen apply
fi

# vim-superman to replace the man page editor with vim
vman() {
  vim -c "SuperMan $*"

  if [ "$?" != "0" ]; then
    echo "No manual entry for $*"
  fi
}
compdef vman="man"

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
