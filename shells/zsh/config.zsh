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
  antigen theme daveverwer

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

# Completion settings for teamocil
if [ $(command_exists teamocil) ]; then
  compctl -g '~/.teamocil/*(:t:r)' teamocil
fi

alias cat='bat'
alias la="exa -abghl --git --color=automatic"
alias ll="exa -bghl --git --color=automatic"
alias ping='prettyping --nolegend'
alias top='htop'
alias du='ncdu --color dark -rr -x --exclude .git --exclude node_modules'
alias help='tldr'
alias rm='trash'
alias cp='cp -i'
alias go='git open'
