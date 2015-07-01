#!/usr/bin/env bash

#DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
DIR="$HOME/.dotfiles"

if [ ! -d "$DIR" ]; then
  echo "Installing dotfiles for the first time."
  git clone https:://github.com/jondong/dotfiles.git "$DIR"
  pushd "$DIR" > /dev/null
else
  echo "Already installed dotfiles, updating..."
  pushd "$DIR" > /dev/null
  git pull --rebase origin master
fi

popd > /dev/null
