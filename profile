#!/bin/bash
# $HOME/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if $HOME/.bash_profile or $HOME/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

prepend_path_if_exists() {
  if [ -d "$1" ]; then
    export PATH="$1":$PATH
  fi
}

append_path_if_exists() {
  if [ -d "$1" ]; then
    export PATH=$PATH:"$1"
  fi
}

prepend_pwd_to_path() {
  prepend_path_if_exists $(pwd)
}

append_pwd_to_path() {
  append_path_if_exists $(pwd)
}

set_proxy() {
  export http_proxy="$1"
  export https_proxy="$1"
}

set_npm_proxy() {
  export npm_config_proxy="$1"
  export npm_config_https_proxy="$1"
}

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi

#Add ssh key for sync playbook repos.
if [ -d "$HOME/resource/backup-keys" ] ; then
  ssh-add "$HOME/resource/backup-keys/id_rsa" > /dev/null 2>&1
fi

# set PATH so it includes user's private bin if it exists
prepend_path_if_exists "$HOME/bin"

export PROJECT_ROOT=$HOME/projects

export EDITOR=vim

# Add dotfiles scripts path
export DOTFILES_ROOT="$HOME/.dotfiles"
prepend_path_if_exists "$DOTFILES_ROOT/bin"

# Scripts in dropbox
prepend_path_if_exists "$HOME/Dropbox/bin"

# Kuaipan (replacement for Dropbox)
if [ -d "$HOME/cloud/快盘" ]; then
  export KUAIPAN_ROOT="$HOME/cloud/快盘"
  export PATH="$KUAIPAN_ROOT/bin":$PATH
elif [ -d "$HOME/cloud/kuaipan" ]; then
  export KUAIPAN_ROOT="$HOME/cloud/kuaipan"
  export PATH="$KUAIPAN_ROOT/bin":$PATH
fi

# Go path
if [ -d "$PROJECT_ROOT/go" ]; then
  export GOPATH=$PROJECT_ROOT/go
  export PATH=$PATH:$GOPATH/bin
fi

# Add depot_tools
DEPOT_TOOLS_HOME=$HOME/bin/depot_tools
prepend_path_if_exists "$DEPOT_TOOLS_HOME"

# Android SDK setup
ANDROID_SDK_ROOT=$HOME/bin/android-sdk
append_path_if_exists "$ANDROID_SDK_ROOT/tools"
append_path_if_exists "$ANDROID_SDK_ROOT/platform-tools"

# Coverity config
export COVERITY_UNSUPPORTED=1
prepend_path_if_exists "$HOME/bin/cov-analysis/bin"

# Local configuration
if [ -f "$HOME/bin/local-conf" ]; then
  source "$HOME/bin/local-conf"
fi

if [ "$(uname)" = 'Linux' ]; then
  ## For gitup setup.
  ## gitup is a tool to sync multiple git repos in a single shot.
  ## For more information please refer to: https://github.com/earwig/git-repo-updater
  append_path_if_exists "$HOME/.local/bin"

  ## Dropbox setup
  ## You need to download dropboxy.py and put it into ~/bin/.
  ## For more information please refer to: https://www.dropbox.com/install?os=lnx
  which dropbox.py > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    dropbox.py running
    if [ $? -eq 0 ]; then
      echo "Dropbox is not running, start it."
      dropbox.py start
      dropbox.py autostart y
    fi
  fi

  ## Ant setup
  ANT_BIN_PATH=$HOME/bin/apache-ant/bin
  prepend_path_if_exists "$ANT_BIN_PATH"

  ## JDK setup
  if [ -d "$HOME/bin/jdk" ]; then
    export JAVA_HOME=$HOME/bin/jdk
    JDK_BIN_PATH=$JAVA_HOME/bin
    prepend_path_if_exists "$JDK_BIN_PATH"
  fi

elif [ "$(uname)" = 'Darwin' ]; then
  # Path for python binaries
  append_path_if_exists "$HOME/Library/Python/2.7/bin"

  # Home for BaiduPan
  export BAIDU_YUNPAN_ROOT="$HOME/cloud/百度云同步盘"

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
fi

