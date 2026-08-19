#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "test-linux-config: Linux is required" >&2
  exit 1
fi

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
test_home=$(mktemp -d)
trap 'rm -rf "$test_home"' EXIT

ln -s "$repo_root" "$test_home/.dotfiles"

HOME="$test_home" \
XDG_CONFIG_HOME="$test_home/xdg" \
SHELL=/bin/bash \
bash -c '
  source <(sed "\$d" "$HOME/.dotfiles/bootstrap.sh")
  overwrite_all=false
  backup_all=false
  skip_all=false
  AUTO_MODE=true
  setup_ghostty
  setup_herdr

  test "$(readlink "$XDG_CONFIG_HOME/ghostty/config.ghostty")" = \
    "$HOME/.dotfiles/apps/ghostty/config.ghostty"
  test "$(readlink "$HOME/.config/herdr/config.toml")" = \
    "$HOME/.dotfiles/apps/herdr/config.toml"
'

fallback_output=$(
  env -i \
    HOME="$test_home" \
    SHELL=/bin/echo \
    PATH=/usr/bin:/bin \
    "$repo_root/bin/herdr-launcher" 2>&1
)
grep -q "Herdr not found" <<<"$fallback_output"
grep -q -- "-l" <<<"$fallback_output"

echo "Linux config smoke test passed"
