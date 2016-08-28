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
  antigen bundle zsh-users/zsh-syntax-highlighting
  antigen bundle zsh-users/zsh-completions

  # Load the theme.
  antigen theme daveverwer

  # Tell antigen that you're done.
  antigen apply

  function git_prompt_info() {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    #echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$ZSH_THEME_GIT_PROMPT_SUFFIX"
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}${ZSH_THEME_GIT_PROMPT_CLEAN}${ZSH_THEME_GIT_PROMPT_SUFFIX}"
  }
fi

# vim-superman to replace the man page editor with vim
vman() {
  vim -c "SuperMan $*"

  if [ "$?" != "0" ]; then
    echo "No manual entry for $*"
  fi
}
compdef vman="man"
