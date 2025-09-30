#!/bin/bash

# Common utility functions
# Provides reusable utilities across all scripts

# Source common dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging.sh"
source "$SCRIPT_DIR/platform-detect.sh"

# File and directory utilities
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_debug "Created directory: $dir"
    fi
}

backup_file() {
    local file="$1"
    local backup_dir="${2:-$HOME/.dotfiles-backups}"

    if [[ -f "$file" ]]; then
        ensure_dir "$backup_dir"
        local backup_file="$backup_dir/$(basename "$file").backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup_file"
        log_info "Backed up $file to $backup_file"
        echo "$backup_file"
    fi
}

safe_symlink() {
    local source="$1"
    local target="$2"
    local backup_dir="${3:-$HOME/.dotfiles-backups}"

    if [[ -e "$target" ]]; then
        if [[ -L "$target" ]]; then
            local current_target=$(readlink "$target")
            if [[ "$current_target" == "$source" ]]; then
                log_debug "Symlink already exists: $target -> $source"
                return 0
            else
                log_info "Removing existing symlink: $target -> $current_target"
                rm "$target"
            fi
        else
            backup_file "$target" "$backup_dir"
            rm -rf "$target"
        fi
    fi

    ensure_dir "$(dirname "$target")"
    ln -s "$source" "$target"
    log_info "Created symlink: $target -> $source"
}

# Command utilities
command_exists() {
    command -v "$1" > /dev/null 2>&1
}

require_command() {
    local cmd="$1"
    local package_hint="${2:-$cmd}"

    if ! command_exists "$cmd"; then
        log_error "Required command not found: $cmd"
        log_info "Please install: $package_hint"
        return 1
    fi
}

version_compare() {
    local version1="$1"
    local version2="$2"

    # Simple version comparison (works for semantic versions)
    if [[ "$version1" == "$version2" ]]; then
        echo "equal"
    else
        # Use sort -V for proper version comparison
        local sorted=$(printf "%s\n%s" "$version1" "$version2" | sort -V | head -n1)
        if [[ "$sorted" == "$version1" ]]; then
            echo "older"
        else
            echo "newer"
        fi
    fi
}

# Configuration utilities
get_dotfiles_root() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")/.." && pwd)"
    echo "$script_dir"
}

is_dotfile_managed() {
    local file="$1"
    local dotfiles_root=$(get_dotfiles_root)

    # Check if file is a symlink pointing to dotfiles
    if [[ -L "$file" ]]; then
        local target=$(readlink "$file")
        [[ "$target" == "$dotfiles_root"* ]]
    else
        return 1
    fi
}

find_broken_symlinks() {
    local dir="${1:-$HOME}"
    find "$dir" -type l -exec test ! -e {} \; -print 2>/dev/null
}

# Package utilities
is_package_installed() {
    local package="$1"
    local package_manager=$(detect_package_manager)

    case "$package_manager" in
        "homebrew")
            brew list "$package" > /dev/null 2>&1
            ;;
        "apt")
            dpkg -l "$package" > /dev/null 2>&1
            ;;
        "yum"|"dnf")
            rpm -q "$package" > /dev/null 2>&1
            ;;
        "pacman")
            pacman -Qi "$package" > /dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

# Performance utilities
time_command() {
    local start_time=$(date +%s.%N)
    "$@"
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    echo "$duration"
}

# JSON utilities (requires jq)
json_get() {
    local file="$1"
    local key="$2"
    local default="${3:-null}"

    if command_exists jq; then
        jq -r ".$key // \"$default\"" "$file" 2>/dev/null || echo "$default"
    else
        log_warn "jq not found, cannot parse JSON"
        echo "$default"
    fi
}

# Git utilities
is_git_repo() {
    local dir="${1:-$(pwd)}"
    [[ -d "$dir/.git" ]]
}

git_repo_status() {
    local dir="${1:-$(pwd)}"

    if is_git_repo "$dir"; then
        cd "$dir"
        local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        local status=$(git status --porcelain 2>/dev/null | wc -l)
        local ahead=$(git rev-list --count origin/"$branch"..HEAD 2>/dev/null || echo "0")
        local behind=$(git rev-list --count HEAD..origin/"$branch" 2>/dev/null || echo "0")

        echo "Branch: $branch, Modified: $status, Ahead: $ahead, Behind: $behind"
    else
        echo "Not a git repository"
    fi
}

# Network utilities
is_online() {
    if ping -c 1 -W 3 8.8.8.8 > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

download_file() {
    local url="$1"
    local output="$2"

    if command_exists curl; then
        curl -fsSL "$url" -o "$output"
    elif command_exists wget; then
        wget -q "$url" -O "$output"
    else
        log_error "Neither curl nor wget found"
        return 1
    fi
}

# Validation utilities
validate_email() {
    local email="$1"
    [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

validate_url() {
    local url="$1"
    [[ "$url" =~ ^https?:// ]]
}

# User interaction utilities
ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"

    while true; do
        if [[ "$default" == "y" ]]; then
            read -p "$prompt [Y/n]: " response
            response=${response:-y}
        else
            read -p "$prompt [y/N]: " response
            response=${response:-n}
        fi

        case "$response" in
            [Yy]|[Yy][Ee][Ss])
                return 0
                ;;
            [Nn]|[Nn][Oo])
                return 1
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
}

ask_choice() {
    local prompt="$1"
    shift
    local options=("$@")

    echo "$prompt"
    for i in "${!options[@]}"; do
        echo "$((i+1))) ${options[i]}"
    done

    while true; do
        read -p "Enter choice (1-${#options[@]}): " response
        if [[ "$response" =~ ^[0-9]+$ ]] && [[ "$response" -ge 1 ]] && [[ "$response" -le "${#options[@]}" ]]; then
            echo "${options[$((response-1))]}"
            return 0
        else
            echo "Please enter a number between 1 and ${#options[@]}"
        fi
    done
}

# Export functions if sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f ensure_dir backup_file safe_symlink
    export -f command_exists require_command version_compare
    export -f get_dotfiles_root is_dotfile_managed find_broken_symlinks
    export -f is_package_installed time_command
    export -f json_get is_git_repo git_repo_status
    export -f is_online download_file
    export -f validate_email validate_url
    export -f ask_yes_no ask_choice
fi