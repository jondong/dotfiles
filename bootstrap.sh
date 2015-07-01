#!/usr/bin/env bash

#DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
DIR="$HOME/.jondong"

if [ ! -d "$DIR" ]; then
  echo "Installing jondong's dotfiles for the first time."
  git clone https:://github.com/jondong/dotfiles.git "$DIR"
  pushd "$DIR" > /dev/null
else
  echo "Already installed jondong's dotfiles, updating..."
  pushd "$DIR" > /dev/null
  git pull --rebase origin master
fi

popd > /dev/null
