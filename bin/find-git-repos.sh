#!/bin/bash

output_file="git_repos.txt"

function check_git_repo() {
  local dir="$1"
  if [ -d "$dir/.git" ]; then
    local git_url
    git_url=$(cd "$dir" && git config --get remote.origin.url)
    if [ -n "$git_url" ]; then
      echo "Git repository found in $dir"
      echo "Git URL: $git_url"
      echo "------------------------"
      # 将路径和URL作为键值对写入文件
      echo "$dir: $git_url" >>"$output_file"
    fi
    return 0
  fi
  return 1
}

function traverse_directory() {
  local dir="$1"
  for item in "$dir"/*; do
    if [ -d "$item" ]; then
      if ! check_git_repo "$item"; then
        traverse_directory "$item"
      fi
    fi
  done
}

# 检查是否提供了目录参数
if [ $# -eq 0 ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# 检查提供的目录是否存在
if [ ! -d "$1" ]; then
  echo "Error: Directory '$1' does not exist."
  exit 1
fi

# 开始遍历目录
traverse_directory "$1"
