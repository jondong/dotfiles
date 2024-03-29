#!/usr/bin/env bash

#
# tmux start script from:
# http://www.huyng.com/posts/productivity-boost-with-tmux-iterm2-workspaces/
#

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH=$PATH:$(brew --prefix)/bin

# abort if we're already inside a TMUX session
[ "$TMUX" == "" ] || exit 0

# startup a "default" session if none currently exists
tmux has-session -t _default || tmux new-session -s _default -d

# present menu for user to choose which workspace to open
PS3="Please choose your session: "
options=($(tmux list-sessions -F "#S") "NEW SESSION" "BASH" "ZSH")
echo "Available sessions"
echo "------------------"
echo " "
select opt in "${options[@]}"
do
    case $opt in
        "NEW SESSION")
            read -p "Enter new session name: " SESSION_NAME
            tmux new -s "$SESSION_NAME"
            break
            ;;
        "BASH")
            bash --login
            break;;
        "ZSH")
            zsh --login
            break;;
        *)
            tmux attach-session -t $opt
            break
            ;;
    esac
done
