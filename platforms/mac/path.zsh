# Append necessary path to PATH for Mac.

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

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
