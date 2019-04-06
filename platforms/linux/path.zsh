# Append necessary path to PATH for Linux.

source /usr/share/autojump/autojump.zsh

## For gitup setup.
## gitup is a tool to sync multiple git repos in a single shot.
## For more information please refer to: https://github.com/earwig/git-repo-updater
append_path_if_exists "$HOME/.local/bin"
append_path_if_exists "$HOME/.cargo/bin"

## Ant setup
ANT_BIN_PATH=$HOME/bin/apache-ant/bin
prepend_path_if_exists "$ANT_BIN_PATH"

## JDK setup
if [ -d "$HOME/bin/jdk" ]; then
  export JAVA_HOME=$HOME/bin/jdk
  JDK_BIN_PATH=$JAVA_HOME/bin
  prepend_path_if_exists "$JDK_BIN_PATH"
fi
