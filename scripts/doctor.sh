#!/usr/bin/env bash
set -uo pipefail

readonly DOTFILES_ROOT="$HOME/.dotfiles"
AUTO_MODE=false

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
NC=$'\033[0m'

ok()    { echo -e "  ${GREEN}OK${NC}      $1"; }
warn()  { echo -e "  ${YELLOW}WARN${NC}    $1"; }
fail()  { echo -e "  ${RED}FAIL${NC}    $1"; }
fix()   { echo -e "  ${BLUE}FIX${NC}     $1"; }
ask() {
    [[ "$AUTO_MODE" == "true" ]] && return 0
    local prompt="$1"
    read -p "  $prompt [Y/n] " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Nn]$ ]]
}

ISSUES=0
FIXES=0

#==============================================================================
# 1. Symlink integrity
#==============================================================================
check_symlinks() {
    echo -e "\n${BLUE}== Symlinks ==${NC}"

    if [[ ! -d "$DOTFILES_ROOT" ]]; then
        fail "Dotfiles root not found: $DOTFILES_ROOT"
        return
    fi

    local broken=0
    local total=0

    while IFS= read -r src; do
        [[ -z "$src" ]] && continue
        local name
        name=$(basename "${src%.*}")
        local dst="$HOME/.$name"
        total=$((total + 1))

        if [[ ! -L "$dst" ]]; then
            if [[ -e "$dst" ]]; then
                warn "$dst exists but is not a symlink"
            else
                fail "$dst -> $src (missing)"
                broken=$((broken + 1))
            fi
        elif [[ "$(readlink "$dst")" != "$src" ]]; then
            fail "$dst points to wrong target: $(readlink "$dst")"
            broken=$((broken + 1))
        else
            ok ".$name"
        fi
    done < <(find "$DOTFILES_ROOT" -maxdepth 3 \( -name "*.symlink" -o -name "*.macsymlink" -o -name "*.linuxsymlink" \) 2>/dev/null)

    echo "  $((total - broken))/$total symlinks valid"

    if [[ $broken -gt 0 ]]; then
        ISSUES=$((ISSUES + 1))
        if ask "Re-run bootstrap to fix symlinks?"; then
            bash "$DOTFILES_ROOT/bootstrap.sh" --skip-update --auto --skip-health
            FIXES=$((FIXES + 1))
        fi
    fi
}

#==============================================================================
# 2. Shell config syntax
#==============================================================================
check_shell_syntax() {
    echo -e "\n${BLUE}== Shell Config Syntax ==${NC}"

    local failed=0
    local total=0

    for f in "$DOTFILES_ROOT/shells/zsh"/*.symlink \
             "$DOTFILES_ROOT/shells/zsh/common"/*.zsh \
             "$DOTFILES_ROOT/shells/zsh/linux"/*.zsh \
             "$DOTFILES_ROOT/shells/zsh/mac"/*.zsh; do
        [[ ! -f "$f" ]] && continue
        total=$((total + 1))
        local rel="${f#$DOTFILES_ROOT/}"
        if zsh -n "$f" 2>/dev/null; then
            ok "$rel"
        else
            fail "$rel"
            zsh -n "$f" 2>&1 | sed 's/^/    /'
            failed=$((failed + 1))
        fi
    done

    echo "  $((total - failed))/$total files valid"

    if [[ $failed -gt 0 ]]; then
        ISSUES=$((ISSUES + 1))
        warn "Fix syntax errors in the files above (manual fix required)"
    fi
}

#==============================================================================
# 3. Required tools
#==============================================================================
check_tools() {
    echo -e "\n${BLUE}== Required Tools ==${NC}"

    local missing=0
    local platform
    platform=$(uname)

    local tools=("git" "curl" "zsh" "tmux")
    [[ "$platform" == "Darwin" || "$platform" == "Linux" ]] && tools+=("nvim")

    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            ok "$tool: $(command -v "$tool")"
        else
            fail "$tool: not installed"
            missing=$((missing + 1))
        fi
    done

    if [[ $missing -gt 0 ]]; then
        ISSUES=$((ISSUES + 1))
        case "$platform" in
            Darwin) warn "Install with: brew install ${tools[*]}" ;;
            Linux)  warn "Install with: sudo apt install ${tools[*]}" ;;
        esac
    fi
}

#==============================================================================
# 4. Zinit
#==============================================================================
check_zinit() {
    echo -e "\n${BLUE}== Zinit ==${NC}"

    local zinit_dir="$HOME/.local/share/zinit/zinit.git"
    if [[ -f "$zinit_dir/zinit.zsh" ]]; then
        ok "Zinit installed"
    else
        fail "Zinit not found (will be auto-installed on first zsh start)"
    fi
}

#==============================================================================
# 5. Git status
#==============================================================================
check_git() {
    echo -e "\n${BLUE}== Git Status ==${NC}"

    if [[ ! -d "$DOTFILES_ROOT/.git" ]]; then
        fail "Not a git repository"
        ISSUES=$((ISSUES + 1))
        return
    fi

    local branch
    branch=$(git -C "$DOTFILES_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null)
    ok "Branch: $branch"

    local uncommitted
    uncommitted=$(git -C "$DOTFILES_ROOT" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [[ $uncommitted -gt 0 ]]; then
        warn "$uncommitted uncommitted changes"
    else
        ok "Working tree clean"
    fi
}

#==============================================================================
# Main
#==============================================================================
main() {
    if [[ "${1:-}" == "--auto" ]]; then
        AUTO_MODE=true
    fi

    echo -e "${BLUE}Dotfiles Doctor${NC}"

    check_symlinks
    check_shell_syntax
    check_tools
    check_zinit
    check_git

    echo ""
    if [[ $ISSUES -eq 0 ]]; then
        echo -e "${GREEN}All checks passed!${NC}"
    else
        echo -e "${YELLOW}Found $ISSUES issue(s)${NC}"
    fi
}

main "$@"
