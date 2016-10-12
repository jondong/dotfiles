# Append necessary path to PATH for Linux.

if [ $PLATFORM = 'Linux' ]; then
  source /usr/share/autojump/autojump.zsh

  if [ $(command_exists source-highlight) ]; then
    export LESSOPEN="/usr/share/source-highlight/src-hilite-lesspipe.sh %s"
    export LESS=' -R '

    alias ccat='/usr/share/source-highlight/src-hilite-lesspipe.sh'
    alias cat=ccat
  fi
fi
