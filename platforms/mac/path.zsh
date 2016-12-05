# Append necessary path to PATH for Mac.

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
  return
fi
export PATH=$EXTRA_LIB_PREFIX/bin:$EXTRA_LIB_PREFIX/sbin:$PATH
export LD_LIBRARY_PATH=$EXTRA_LIB_PREFIX/lib:$LD_LIBRARY_PATH
