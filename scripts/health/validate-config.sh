#!/bin/bash

# Configuration File Validation Tool
# Validates syntax and structure of all configuration files

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

# Global counters
TOTAL_VALIDATIONS=0
PASSED_VALIDATIONS=0
FAILED_VALIDATIONS=0

# Configuration file validation functions
validate_shell_config() {
    local file="$1"
    local shell_type="$2"

    if [[ ! -f "$file" ]]; then
        return 0  # File doesn't exist, skip validation
    fi

    case "$shell_type" in
        "bash")
            if bash -n "$file" 2>/dev/null; then
                return 0
            else
                return 1
            fi
            ;;
        "zsh")
            if zsh -n "$file" 2>/dev/null; then
                return 0
            else
                return 1
            fi
            ;;
    esac
}

validate_toml_config() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        return 0
    fi

    # Try different TOML validation methods
    if command_exists alacritty && [[ "$file" == *"alacritty"* ]]; then
        if timeout 5s alacritty --config-file "$file" --help >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    elif command_exists chezmoi; then
        if chezmoi verify "$file" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    elif command_exists toml; then
        if toml "$file" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    else
        # Basic syntax check
        if grep -q '^\[' "$file" && ! grep -q '^  \[' "$file"; then
            return 0
        else
            return 1
        fi
    fi
}

validate_json_config() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        return 0
    fi

    if command_exists jq; then
        if jq . "$file" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    else
        # Basic JSON syntax check
        if python3 -m json.tool "$file" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    fi
}

validate_yaml_config() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        return 0
    fi

    if command_exists yamllint; then
        if yamllint "$file" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    elif command_exists python3 && python3 -c "import yaml" >/dev/null 2>&1; then
        if python3 -c "import yaml; yaml.safe_load(open('$file'))" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    else
        # Basic YAML structure check
        if grep -q '^---' "$file" || grep -q '^  [a-zA-Z]' "$file"; then
            return 0
        else
            return 1
        fi
    fi
}

validate_git_config() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        return 0
    fi

    if git config --file "$file" --list >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

validate_tmux_config() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        return 0
    fi

    if tmux -f "$file" start-server \; list-sessions >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

validate_vim_config() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        return 0
    fi

    # Basic vim script syntax check
    if vim -c "source $file | q" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Configuration file registry
declare -A CONFIG_FILES=(
    # Shell configurations
    ["$HOME/.zshrc"]="zsh:ZSH configuration"
    ["$HOME/.zshenv"]="zsh:ZSH environment"
    ["$HOME/.zprofile"]="zsh:ZSH profile"
    ["$HOME/.bashrc"]="bash:Bash configuration"
    ["$HOME/.bash_profile"]="bash:Bash profile"
    ["$HOME/.profile"]="bash:Shell profile"

    # Application configurations
    ["$HOME/.gitconfig"]="git:Git configuration"
    ["$HOME/.tmux.conf"]="tmux:Tmux configuration"
    ["$HOME/.vimrc"]="vim:Vim configuration"
    ["$HOME/.config/alacritty/alacritty.toml"]="toml:Alacritty configuration"
    ["$HOME/.config/hyper/hyper.js"]="json:Hyper terminal configuration"
    ["$HOME/.config/nvim/init.vim"]="vim:Neovim configuration"
    ["$HOME/.config/starship.toml"]="toml:Starship prompt configuration"

    # Development tools
    ["$HOME/.config/fish/config.fish"]="fish:Fish shell configuration"
    ["$HOME/.config/karabiner/karabiner.json"]="json:Karabiner configuration"
    ["$HOME/.config/iterm2/com.googlecode.iterm2.plist"]="plist:iTerm2 configuration"

    # SSH and security
    ["$HOME/.ssh/config"]="ssh:SSH client configuration"
    ["$HOME/.ssh/known_hosts"]="ssh:SSH known hosts"
)

validate_single_config() {
    local config_file="$1"
    local config_info="$2"

    local validator_type="${config_info%%:*}"
    local description="${config_info#*:}"

    if [[ ! -f "$config_file" ]]; then
        log_debug "Config file not found: $config_file"
        return 0
    fi

    local validation_result=0

    case "$validator_type" in
        "bash")
            validate_shell_config "$config_file" "bash"
            validation_result=$?
            ;;
        "zsh")
            validate_shell_config "$config_file" "zsh"
            validation_result=$?
            ;;
        "toml")
            validate_toml_config "$config_file"
            validation_result=$?
            ;;
        "json")
            validate_json_config "$config_file"
            validation_result=$?
            ;;
        "yaml")
            validate_yaml_config "$config_file"
            validation_result=$?
            ;;
        "git")
            validate_git_config "$config_file"
            validation_result=$?
            ;;
        "tmux")
            validate_tmux_config "$config_file"
            validation_result=$?
            ;;
        "vim")
            validate_vim_config "$config_file"
            validation_result=$?
            ;;
        "fish")
            validate_shell_config "$config_file" "fish"
            validation_result=$?
            ;;
        "ssh")
            # SSH config validation
            if ssh -G -F "$config_file" dummy_host >/dev/null 2>&1; then
                validation_result=0
            else
                validation_result=1
            fi
            ;;
        "plist")
            # Basic plist validation
            if plutil -lint "$config_file" >/dev/null 2>&1; then
                validation_result=0
            else
                validation_result=1
            fi
            ;;
        *)
            log_warn "Unknown validator type: $validator_type"
            validation_result=1
            ;;
    esac

    if [[ $validation_result -eq 0 ]]; then
        status_ok "$description: Valid"
        ((PASSED_VALIDATIONS++))
    else
        status_error "$description: Invalid"
        ((FAILED_VALIDATIONS++))
    fi

    ((TOTAL_VALIDATIONS++))
}

validate_symlinks() {
    section "Symlink Validation"

    local broken_symlinks=0
    local total_checked=0

    while IFS= read -r symlink; do
        if [[ -n "$symlink" ]]; then
            ((total_checked++))
            ((broken_symlinks++))
            status_error "Broken symlink: $symlink"
            ((FAILED_VALIDATIONS++))
        fi
    done < <(find_broken_symlinks "$HOME" | head -10)

    ((TOTAL_VALIDATIONS += total_checked))

    if [[ $broken_symlinks -eq 0 ]]; then
        status_ok "No broken symlinks found"
        ((PASSED_VALIDATIONS++))
        ((TOTAL_VALIDATIONS++))
    fi
}

validate_dotfiles_integrity() {
    section "Dotfiles Repository Integrity"

    local dotfiles_root=$(get_dotfiles_root)

    if ! is_git_repo "$dotfiles_root"; then
        status_error "Dotfiles is not a git repository"
        ((FAILED_VALIDATIONS++))
        ((TOTAL_VALIDATIONS++))
        return
    fi

    # Check for uncommitted changes
    cd "$dotfiles_root"
    local uncommitted_files=$(git status --porcelain 2>/dev/null | wc -l)

    if [[ $uncommitted_files -eq 0 ]]; then
        status_ok "No uncommitted changes"
        ((PASSED_VALIDATIONS++))
    else
        status_warn "$uncommitted_files uncommitted files"
        ((FAILED_VALIDATIONS++))
    fi
    ((TOTAL_VALIDATIONS++))

    # Check for common issues
    local issues_found=0

    # Check for large files
    if find "$dotfiles_root" -type f -size +10M 2>/dev/null | grep -q .; then
        status_warn "Found files larger than 10MB in dotfiles"
        ((issues_found++))
    fi

    # Check for binary files
    if find "$dotfiles_root" -type f -name "*.exe" -o -name "*.dll" -o -name "*.so" 2>/dev/null | grep -q .; then
        status_warn "Found binary files in dotfiles"
        ((issues_found++))
    fi

    # Check for sensitive files
    local sensitive_patterns=("*.key" "*.pem" "*.p12" "password" "secret" "api_key")
    for pattern in "${sensitive_patterns[@]}"; do
        if find "$dotfiles_root" -name "*$pattern*" 2>/dev/null | grep -q .; then
            status_warn "Found potential sensitive files: $pattern"
            ((issues_found++))
        fi
    done

    if [[ $issues_found -eq 0 ]]; then
        status_ok "No repository integrity issues found"
        ((PASSED_VALIDATIONS++))
    else
        status_error "Found $issues_found repository integrity issues"
        ((FAILED_VALIDATIONS++))
    fi
    ((TOTAL_VALIDATIONS++))
}

validate_platform_configs() {
    section "Platform-Specific Configurations"

    local platform=$(detect_platform)
    log_info "Validating configurations for platform: $platform"

    # Platform-specific validations
    case "$platform" in
        "macos")
            # Validate macOS-specific configs
            local macos_configs=(
                "$HOME/Library/Preferences/com.apple.Terminal.plist"
                "$HOME/.config/hammerspoon/init.lua"
                "$HOME/.config/yabai/yabairc"
            )

            for config in "${macos_configs[@]}"; do
                if [[ -f "$config" ]]; then
                    status_ok "macOS config exists: $(basename "$config")"
                    ((PASSED_VALIDATIONS++))
                else
                    log_debug "macOS config not found: $(basename "$config")"
                fi
                ((TOTAL_VALIDATIONS++))
            done
            ;;
        "linux")
            # Validate Linux-specific configs
            local linux_configs=(
                "$HOME/.config/systemd/user"
                "$HOME/.config/polybar/config"
                "$HOME/.config/i3/config"
            )

            for config in "${linux_configs[@]}"; do
                if [[ -f "$config" ]]; then
                    status_ok "Linux config exists: $(basename "$config")"
                    ((PASSED_VALIDATIONS++))
                else
                    log_debug "Linux config not found: $(basename "$config")"
                fi
                ((TOTAL_VALIDATIONS++))
            done
            ;;
    esac
}

# Validation report generation
generate_validation_report() {
    local report_file="${1:-/tmp/dotfiles-validation-report.txt}"

    {
        echo "Dotfiles Configuration Validation Report"
        echo "=========================================="
        echo "Date: $(date)"
        echo "Platform: $(detect_platform)"
        echo ""
        echo "Summary:"
        echo "  Total validations: $TOTAL_VALIDATIONS"
        echo "  Passed: $PASSED_VALIDATIONS"
        echo "  Failed: $FAILED_VALIDATIONS"
        echo ""
        echo "Success rate: $(( PASSED_VALIDATIONS * 100 / TOTAL_VALIDATIONS ))%"
        echo ""

        if [[ $FAILED_VALIDATIONS -gt 0 ]]; then
            echo "Issues found that need attention:"
            echo "=================================="
        fi
    } > "$report_file"

    if [[ $FAILED_VALIDATIONS -gt 0 ]]; then
        echo "Validation report saved to: $report_file"
    fi
}

# Main execution
main() {
    echo -e "${WHITE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                   Configuration Validation                   ║
║                    Syntax and Structure Check                 ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    # Validate all registered configuration files
    section "Configuration Files Validation"
    for config_file in "${!CONFIG_FILES[@]}"; do
        validate_single_config "$config_file" "${CONFIG_FILES[$config_file]}"
    done

    # Additional validation checks
    validate_symlinks
    validate_dotfiles_integrity
    validate_platform_configs

    # Generate summary
    local success_rate=$(( PASSED_VALIDATIONS * 100 / TOTAL_VALIDATIONS ))
    echo -e "\n${WHITE}=== Validation Summary ===${NC}"
    echo "Total validations: $TOTAL_VALIDATIONS"
    echo -e "Passed: ${GREEN}$PASSED_VALIDATIONS${NC}"
    echo -e "Failed: ${RED}$FAILED_VALIDATIONS${NC}"
    echo "Success rate: ${success_rate}%"

    if [[ $FAILED_VALIDATIONS -eq 0 ]]; then
        echo -e "\n${GREEN}🎉 All configuration files are valid!${NC}"
        exit 0
    else
        echo -e "\n${RED}❌ Found $FAILED_VALIDATIONS configuration issues.${NC}"
        generate_validation_report
        exit 1
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi