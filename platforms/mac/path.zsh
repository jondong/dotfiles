# Append necessary path to PATH for Mac.

# nvm configuration.
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
alias cat='ccat'

# autojump configuration.
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh

# Path for python binaries
append_path_if_exists "$HOME/Library/Python/2.7/bin"

if [ -d /opt/local ]; then
  # using Macports
  EXTRA_LIB_PREFIX=/opt/local
elif [ -d /usr/local ]; then
  # using Homebrew
  EXTRA_LIB_PREFIX=/usr/local
fi

if [ -z $EXTRA_LIB_PREFIX ]; then
  exit
fi
export PATH=$EXTRA_LIB_PREFIX/bin:$EXTRA_LIB_PREFIX/sbin:$PATH
export LD_LIBRARY_PATH=$EXTRA_LIB_PREFIX/lib:$LD_LIBRARY_PATH

# MacPorts Bash shell command completion
if [ -f $EXTRA_LIB_PREFIX/etc/bash_completion ]; then
    . $EXTRA_LIB_PREFIX/etc/bash_completion
    source $EXTRA_LIB_PREFIX/share/git/git-prompt.sh
fi

# Homebrew bash shell command completion
if [ -d $EXTRA_LIB_PREFIX/etc/bash_completion.d ]; then
    source $EXTRA_LIB_PREFIX/etc/bash_completion.d/git-extras
fi
