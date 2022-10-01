# Append necessary path to PATH for Mac.

if [ -d $(brew --prefix) ]; then
  # using Homebrew
  EXTRA_LIB_PREFIX=$(brew --prefix)
elif [ -d /opt/local ]; then
  # using Macports
  EXTRA_LIB_PREFIX=/opt/local
fi

if [ -z $EXTRA_LIB_PREFIX ]; then
  return
fi
export PATH=$EXTRA_LIB_PREFIX/bin:$EXTRA_LIB_PREFIX/sbin:$PATH
export LD_LIBRARY_PATH=$EXTRA_LIB_PREFIX/lib:$LD_LIBRARY_PATH


# autojump configuration.
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh

# z configuration
. $(brew --prefix)/etc/profile.d/z.sh
