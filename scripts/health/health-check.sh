#!/bin/bash

# Comprehensive System Health Check
# Monitors all aspects of the dotfiles environment

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

# Global counters for summary
TOTAL_CHECKS=0
PASSED_CHECKS=0
WARNING_CHECKS=0
ERROR_CHECKS=0

# Health check functions
check_symlinks() {
    section "Symlink Health Check"

    local broken_symlinks=0
    local total_symlinks=0

    # Check for broken symlinks in home directory
    while IFS= read -r symlink; do
        if [[ -n "$symlink" ]]; then
            total_symlinks=$((total_symlinks + 1))
            broken_symlinks=$((broken_symlinks + 1))
            status_error "Broken symlink: $symlink"
        fi
    done < <(find_broken_symlinks "$HOME" | head -20)  # Limit to first 20

    # Check dotfile-specific symlinks
    local dotfile_symlinks=0
    local managed_symlinks=0

    while IFS= read -r -d '' file; do
        if [[ -L "$file" ]]; then
            dotfile_symlinks=$((dotfile_symlinks + 1))
            if is_dotfile_managed "$file"; then
                managed_symlinks=$((managed_symlinks + 1))
            fi
        fi
    done < <(find "$HOME" -maxdepth 2 -type l -print0 2>/dev/null)

    if [[ $broken_symlinks -eq 0 ]]; then
        status_ok "No broken symlinks found"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        status_error "Found $broken_symlinks broken symlinks"
        ERROR_CHECKS=$((ERROR_CHECKS + 1))
    fi

    if [[ $dotfile_symlinks -gt 0 ]]; then
        local percentage=$((managed_symlinks * 100 / dotfile_symlinks))
        if [[ $percentage -gt 80 ]]; then
            status_ok "$managed_symlinks/$dotfile_symlinks symlinks managed by dotfiles ($percentage%)"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            status_warn "Only $managed_symlinks/$dotfile_symlinks symlinks managed ($percentage%)"
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
        fi
    fi

    ((TOTAL_CHECKS += 2))
}

check_shell_environment() {
    section "Shell Environment Health"

    # Check shell configuration files
    local shell_configs=("$HOME/.zshrc" "$HOME/.zshenv" "$HOME/.zprofile" "$HOME/.zlogin")
    local configs_ok=0

    for config in "${shell_configs[@]}"; do
        if [[ -f "$config" ]]; then
            local shell_type="bash"
            [[ "$config" == *"zsh"* ]] && shell_type="zsh"
            if $shell_type -n "$config" 2>/dev/null; then
                status_ok "Shell config syntax OK: $(basename "$config")"
                configs_ok=$((configs_ok + 1))
            else
                status_error "Shell config syntax error: $(basename "$config")"
                ERROR_CHECKS=$((ERROR_CHECKS + 1))
            fi
        else
            status_warn "Missing shell config: $(basename "$config")"
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    done

    # Check if shell loads without errors
    if timeout 10s zsh -i -c 'echo "Shell test OK"' >/dev/null 2>&1; then
        status_ok "Interactive shell loads without errors"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        status_error "Interactive shell has errors"
        ERROR_CHECKS=$((ERROR_CHECKS + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

check_tools_installation() {
    section "Core Tools Installation"

    # Essential tools to check
    local essential_tools=("git" "curl" "wget" "vim" "tmux" "fzf")
    local optional_tools=("docker" "node" "python3" "java" "go" "rust")

    # Check essential tools
    local essential_missing=0
    for tool in "${essential_tools[@]}"; do
        if command_exists "$tool"; then
            local version=$($tool --version 2>/dev/null | head -1 || echo "version unknown")
            status_ok "$tool: $version"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            status_error "Missing essential tool: $tool"
            essential_missing=$((essential_missing + 1))
            ERROR_CHECKS=$((ERROR_CHECKS + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    done

    # Check optional tools
    for tool in "${optional_tools[@]}"; do
        if command_exists "$tool"; then
            local version=$($tool --version 2>/dev/null | head -1 || echo "version unknown")
            status_ok "$tool: $version"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            status_warn "Optional tool not installed: $tool"
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    done

    # Summary for essential tools
    if [[ $essential_missing -eq 0 ]]; then
        status_ok "All essential tools are installed"
    else
        status_error "$essential_missing essential tools missing"
    fi
}

check_config_files() {
    section "Configuration Files Health"

    # Define config files to check
    declare -A config_files=(
        ["$HOME/.gitconfig"]="Git configuration"
        ["$HOME/.vimrc"]="Vim configuration"
        ["$HOME/.tmux.conf"]="Tmux configuration"
        ["$HOME/.config/alacritty/alacritty.toml"]="Alacritty configuration"
        ["$HOME/.fzf.zsh"]="FZF configuration"
    )

    for config_file in "${!config_files[@]}"; do
        local description="${config_files[$config_file]}"

        if [[ -f "$config_file" ]]; then
            if [[ "$config_file" == *.toml ]] && command_exists alacritty; then
                # Validate TOML files
                if timeout 5s alacritty --config-file "$config_file" --help >/dev/null 2>&1; then
                    status_ok "$description: Valid configuration"
                    PASSED_CHECKS=$((PASSED_CHECKS + 1))
                else
                    status_error "$description: Invalid configuration"
                    ERROR_CHECKS=$((ERROR_CHECKS + 1))
                fi
            elif [[ "$config_file" == *.json ]] && command_exists jq; then
                # Validate JSON files
                if jq . "$config_file" >/dev/null 2>&1; then
                    status_ok "$description: Valid JSON"
                    PASSED_CHECKS=$((PASSED_CHECKS + 1))
                else
                    status_error "$description: Invalid JSON"
                    ERROR_CHECKS=$((ERROR_CHECKS + 1))
                fi
            else
                status_ok "$description: File exists"
                PASSED_CHECKS=$((PASSED_CHECKS + 1))
            fi
        else
            status_warn "$description: Not found"
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    done
}

check_performance() {
    section "System Performance"

    # Check disk space
    local disk_usage=$(df "$HOME" | awk 'NR==2 {print $5}' | sed 's/%//')
    if [[ $disk_usage -lt 80 ]]; then
        status_ok "Disk usage: ${disk_usage}%"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    elif [[ $disk_usage -lt 90 ]]; then
        status_warn "Disk usage: ${disk_usage}% (getting high)"
        WARNING_CHECKS=$((WARNING_CHECKS + 1))
    else
        status_error "Disk usage: ${disk_usage}% (critical)"
        ERROR_CHECKS=$((ERROR_CHECKS + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    # Check memory usage (Linux only)
    if [[ $(detect_platform) == "linux" ]] && [[ -f /proc/meminfo ]]; then
        local mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
        if [[ $mem_usage -lt 80 ]]; then
            status_ok "Memory usage: ${mem_usage}%"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        elif [[ $mem_usage -lt 90 ]]; then
            status_warn "Memory usage: ${mem_usage}% (getting high)"
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
        else
            status_error "Memory usage: ${mem_usage}% (critical)"
            ERROR_CHECKS=$((ERROR_CHECKS + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    fi

    # Check shell startup time
    local startup_time=$(time_command zsh -i -c 'exit' 2>/dev/null)
    if (( $(echo "$startup_time < 2.0" | bc -l) )); then
        status_ok "Shell startup time: ${startup_time}s"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    elif (( $(echo "$startup_time < 5.0" | bc -l) )); then
        status_warn "Shell startup time: ${startup_time}s (slow)"
        WARNING_CHECKS=$((WARNING_CHECKS + 1))
    else
        status_error "Shell startup time: ${startup_time}s (very slow)"
        ERROR_CHECKS=$((ERROR_CHECKS + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

check_network() {
    section "Network Connectivity"

    # Check internet connectivity
    if is_online; then
        status_ok "Internet connectivity: OK"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        status_warn "Internet connectivity: Limited or offline"
        WARNING_CHECKS=$((WARNING_CHECKS + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    # Check GitHub connectivity (for dotfiles updates)
    if curl -s --connect-timeout 5 https://github.com > /dev/null; then
        status_ok "GitHub connectivity: OK"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        status_warn "GitHub connectivity: Limited"
        WARNING_CHECKS=$((WARNING_CHECKS + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

check_dotfiles_repo() {
    section "Dotfiles Repository"

    local dotfiles_root=$(get_dotfiles_root)

    if is_git_repo "$dotfiles_root"; then
        status_ok "Dotfiles is a git repository"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))

        # Check git status
        local status_output=$(git_repo_status "$dotfiles_root")
        if [[ "$status_output" == *"Modified: 0"* ]] && [[ "$status_output" == *"Ahead: 0"* ]]; then
            status_ok "Repository is clean and up to date"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            status_warn "Repository has uncommitted changes or is not up to date"
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
        fi

        # Check for recent activity
        local last_commit=$(git -C "$dotfiles_root" log -1 --format="%ar" 2>/dev/null || echo "unknown")
        status_info "Last commit: $last_commit"
    else
        status_error "Dotfiles is not a git repository"
        ERROR_CHECKS=$((ERROR_CHECKS + 1))
    fi

    ((TOTAL_CHECKS += 2))
}

check_security() {
    section "Security Configuration"

    # Check file permissions
    local ssh_dir="$HOME/.ssh"
    if [[ -d "$ssh_dir" ]]; then
        local ssh_perms
        if [[ "$(uname)" == "Darwin" ]]; then
            ssh_perms=$(stat -f "%A" "$ssh_dir" 2>/dev/null)
        else
            ssh_perms=$(stat -c "%a" "$ssh_dir" 2>/dev/null)
        fi
        if [[ "$ssh_perms" == "700" ]]; then
            status_ok "SSH directory permissions: $ssh_perms"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            status_warn "SSH directory permissions: $ssh_perms (should be 700)"
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

        # Check SSH key permissions
        find "$ssh_dir" -name "id_*" -type f ! -name "*.pub" ! -perm 600 | while read -r key; do
            status_error "SSH private key has incorrect permissions: $(basename "$key") (should be 600)"
            ERROR_CHECKS=$((ERROR_CHECKS + 1))
            TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        done
        find "$ssh_dir" -name "id_*.pub" -type f ! -perm 644 | while read -r key; do
            status_warn "SSH public key has incorrect permissions: $(basename "$key") (should be 644)"
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
            TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        done
    fi

    # Check for exposed API keys or secrets (basic check)
    local config_files=("$HOME/.gitconfig" "$HOME/.netrc" "$HOME/.bashrc" "$HOME/.zshrc")
    for config in "${config_files[@]}"; do
        if [[ -f "$config" ]]; then
            if grep -qi "api_key\|secret\|password\|token" "$config" 2>/dev/null; then
                status_warn "Potential secrets found in: $(basename "$config")"
                WARNING_CHECKS=$((WARNING_CHECKS + 1))
            else
                status_ok "No obvious secrets in: $(basename "$config")"
                PASSED_CHECKS=$((PASSED_CHECKS + 1))
            fi
            TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        fi
    done
}

# Main execution
main() {
    echo -e "${WHITE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                    Dotfiles Health Check                      ║
║                  System Status Monitor                       ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    # Display system info
    subsection "System Information"
    get_system_info

    # Run all health checks
    check_symlinks
    check_shell_environment
    check_tools_installation
    check_config_files
    check_performance
    check_network
    check_dotfiles_repo
    check_security

    # Print summary
    print_summary "$PASSED_CHECKS" "$WARNING_CHECKS" "$ERROR_CHECKS"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi