#!/bin/bash

# Enhanced Dotfiles Bootstrap Script
# One-command setup with interactive environment selection and enhanced features

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"

# Constants
readonly DOTFILES_ROOT=$(get_dotfiles_root)
readonly BACKUP_DIR="$HOME/.dotfiles-backups"
readonly INSTALL_LOG="$BACKUP_DIR/install_$(date +%Y%m%d_%H%M%S).log"

# Installation state
VERBOSE=false
AUTO_MODE=false
WITH_VIM=false
WITH_TMUX=false
PARALLEL=false
DEVELOPMENT_ENVIRONMENT=""
INTERACTIVE_MODE=true

# Development environment templates
declare -A ENVIRONMENTS=(
    ["web"]="Web Development (Node.js, React, Vue, etc.)"
    ["backend"]="Backend Development (Python, Go, Java, etc.)"
    ["mobile"]="Mobile Development (React Native, Flutter, etc.)"
    ["data-science"]="Data Science (Python, R, Jupyter, etc.)"
    ["devops"]="DevOps & Cloud (Docker, K8s, Terraform, etc.)"
    ["minimal"]="Minimal setup (Shell, Git, Vim only)"
    ["full"]="Full development environment (all tools)"
)

# Environment-specific package lists
declare -A ENV_PACKAGES=(
    ["web"]="node npm yarn pnpm nvm"
    ["backend"]="python3 python3-pip go openjdk maven gradle"
    ["mobile"]="node npm nvm flutter android-studio"
    ["data-science"]="python3 python3-pip r-base jupyter pandas numpy"
    ["devops"]="docker kubectl helm terraform aws-cli azure-cli"
    ["minimal"]=""
    ["full"]="node npm yarn pnpm nvm python3 python3-pip go openjdk maven gradle flutter docker kubectl terraform"
)

# Display functions
show_banner() {
    echo -e "${WHITE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                    Enhanced Dotfiles Setup                    ║
║              Cross-Platform Development Environment           ║
║                     One-Command Installer                    ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_help() {
    cat << EOF
Enhanced Dotfiles Bootstrap Script

Usage: $(basename "$0") [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output
    -y, --yes               Auto-mode, skip all confirmations
    --with-vim              Include Vim configuration
    --with-tmux             Include Tmux configuration
    --parallel              Enable parallel package installation
    --env ENVIRONMENT       Development environment (web, backend, mobile,
                            data-science, devops, minimal, full)
    --no-interactive        Non-interactive mode

DEVELOPMENT ENVIRONMENTS:
    web           Web Development (Node.js, React, Vue)
    backend       Backend Development (Python, Go, Java)
    mobile        Mobile Development (React Native, Flutter)
    data-science  Data Science (Python, R, Jupyter)
    devops        DevOps & Cloud (Docker, K8s, Terraform)
    minimal       Minimal setup (Shell, Git, Vim only)
    full          Full development environment

EXAMPLES:
    bootstrap.sh --env web --with-vim --with-tmux
    bootstrap.sh --env devops --parallel --yes
    bootstrap.sh --env minimal --no-interactive

For more information, visit: https://github.com/yourusername/dotfiles
EOF
}

# System detection and validation
detect_system_info() {
    section "System Information"

    local platform=$(detect_platform)
    local distro=$(detect_linux_distro)
    local shell=$(detect_shell)
    local package_manager=$(detect_package_manager)

    log_info "Platform: $platform"
    log_info "Distribution: $distro"
    log_info "Shell: $shell"
    log_info "Package Manager: $package_manager"

    # Check network connectivity
    if is_online; then
        status_ok "Internet connectivity: Available"
    else
        status_warn "Internet connectivity: Limited - some features may not work"
    fi

    # Check disk space
    local available_space=$(df "$HOME" | awk 'NR==2 {print $4}')
    local available_gb=$((available_space / 1024 / 1024))

    if [[ $available_gb -lt 5 ]]; then
        status_error "Low disk space: ${available_gb}GB available"
        return 1
    else
        status_ok "Disk space: ${available_gb}GB available"
    fi

    return 0
}

# Interactive environment selection
select_development_environment() {
    if [[ "$AUTO_MODE" == "true" ]] || [[ "$INTERACTIVE_MODE" == "false" ]]; then
        if [[ -z "$DEVELOPMENT_ENVIRONMENT" ]]; then
            DEVELOPMENT_ENVIRONMENT="minimal"
        fi
        log_info "Using environment: $DEVELOPMENT_ENVIRONMENT"
        return
    fi

    echo -e "\n${WHITE}Select Development Environment:${NC}"
    local env_list=()
    local index=1

    for env in "${!ENVIRONMENTS[@]}"; do
        echo "$index) ${ENVIRONMENTS[$env]}"
        env_list+=("$env")
        ((index++))
    done

    echo
    while true; do
        read -p "Enter choice (1-${#ENVIRONMENTS[@]}): " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "${#ENVIRONMENTS[@]}" ]]; then
            DEVELOPMENT_ENVIRONMENT="${env_list[$((choice-1))]}"
            log_success "Selected: ${ENVIRONMENTS[$DEVELOPMENT_ENVIRONMENT]}"
            break
        else
            log_error "Please enter a number between 1 and ${#ENVIRONMENTS[@]}"
        fi
    done
}

# Package installation
install_system_packages() {
    section "Installing System Packages"

    local platform=$(detect_platform)
    local package_manager=$(detect_package_manager)

    # Get environment-specific packages
    local packages="${ENV_PACKAGES[$DEVELOPMENT_ENVIRONMENT]}"

    if [[ -z "$packages" ]]; then
        log_info "No additional packages required for $DEVELOPMENT_ENVIRONMENT environment"
        return 0
    fi

    log_info "Installing packages for $DEVELOPMENT_ENVIRONMENT environment: $packages"

    case "$platform" in
        "macos")
            install_macos_packages "$packages"
            ;;
        "linux")
            install_linux_packages "$packages"
            ;;
        *)
            log_warn "Package installation not supported on $platform"
            ;;
    esac
}

install_macos_packages() {
    local packages="$1"

    if ! command_exists brew; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Update Homebrew
    log_info "Updating Homebrew..."
    brew update

    # Install packages
    if [[ "$PARALLEL" == "true" ]]; then
        log_info "Installing packages in parallel..."
        echo "$packages" | xargs -P 4 -n 1 brew install
    else
        log_info "Installing packages..."
        for package in $packages; do
            if ! brew list "$package" >/dev/null 2>&1; then
                log_info "Installing $package..."
                brew install "$package"
            else
                log_info "$package already installed"
            fi
        done
    fi
}

install_linux_packages() {
    local packages="$1"
    local package_manager=$(detect_package_manager)

    case "$package_manager" in
        "apt")
            sudo apt update
            for package in $packages; do
                if ! dpkg -l "$package" >/dev/null 2>&1; then
                    log_info "Installing $package..."
                    sudo apt install -y "$package"
                else
                    log_info "$package already installed"
                fi
            done
            ;;
        "yum"|"dnf")
            sudo "$package_manager" update -y
            for package in $packages; do
                if ! "$package_manager" list installed "$package" >/dev/null 2>&1; then
                    log_info "Installing $package..."
                    sudo "$package_manager" install -y "$package"
                else
                    log_info "$package already installed"
                fi
            done
            ;;
        "pacman")
            sudo pacman -Syu --noconfirm
            for package in $packages; do
                if ! pacman -Qi "$package" >/dev/null 2>&1; then
                    log_info "Installing $package..."
                    sudo pacman -S --noconfirm "$package"
                else
                    log_info "$package already installed"
                fi
            done
            ;;
        *)
            log_warn "Package manager $package_manager not supported"
            ;;
    esac
}

# Configuration setup
setup_shell_environment() {
    section "Setting Up Shell Environment"

    # Install and configure Zsh if not present
    if ! command_exists zsh; then
        log_info "Installing Zsh..."
        case $(detect_platform) in
            "macos")
                brew install zsh
                ;;
            "linux")
                case $(detect_package_manager) in
                    "apt") sudo apt install -y zsh ;;
                    "yum"|"dnf") sudo "$package_manager" install -y zsh ;;
                    "pacman") sudo pacman -S --noconfirm zsh ;;
                esac
                ;;
        esac
    fi

    # Change default shell to Zsh
    if [[ "$SHELL" != *"zsh" ]]; then
        log_info "Changing default shell to Zsh..."
        chsh -s "$(which zsh)"
    fi

    # Setup Zsh configuration
    if [[ -x "$SCRIPT_DIR/dotfile-manager.sh" ]]; then
        log_info "Installing shell configurations..."
        "$SCRIPT_DIR/dotfile-manager.sh" install --yes
    fi
}

setup_development_tools() {
    section "Setting Up Development Tools"

    # Install FZF
    if ! command_exists fzf; then
        log_info "Installing FZF..."
        if [[ -d "$HOME/.fzf" ]]; then
            cd "$HOME/.fzf" && git pull && ./install --bin
        else
            git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
            "$HOME/.fzf/install --bin"
        fi
    fi

    # Install Node.js version manager (NVM)
    if [[ "$DEVELOPMENT_ENVIRONMENT" =~ ^(web|mobile|full)$ ]] && ! command_exists nvm; then
        log_info "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    fi

    # Setup Tmux if requested
    if [[ "$WITH_TMUX" == "true" ]]; then
        setup_tmux_environment
    fi

    # Setup Vim if requested
    if [[ "$WITH_VIM" == "true" ]]; then
        setup_vim_environment
    fi

    # Setup environment-specific tools
    case "$DEVELOPMENT_ENVIRONMENT" in
        "web"|"mobile"|"full")
            setup_web_development_tools
            ;;
        "backend"|"full")
            setup_backend_development_tools
            ;;
        "data-science")
            setup_data_science_tools
            ;;
        "devops"|"full")
            setup_devops_tools
            ;;
    esac
}

setup_tmux_environment() {
    if ! command_exists tmux; then
        log_info "Installing Tmux..."
        case $(detect_platform) in
            "macos") brew install tmux ;;
            "linux")
                case $(detect_package_manager) in
                    "apt") sudo apt install -y tmux ;;
                    "yum"|"dnf") sudo "$package_manager" install -y tmux ;;
                    "pacman") sudo pacman -S --noconfirm tmux ;;
                esac
                ;;
        esac
    fi

    # Install Tmux Plugin Manager
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        log_info "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi
}

setup_vim_environment() {
    if command_exists vim; then
        log_info "Setting up Vim configuration..."

        # Install vim-plug if not present
        if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
            log_info "Installing vim-plug..."
            curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
                https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        fi

        # Install plugins
        log_info "Installing Vim plugins..."
        vim +PlugInstall +qall
    fi
}

setup_web_development_tools() {
    log_info "Setting up web development tools..."

    # Install global npm packages
    if command_exists npm; then
        local global_packages=("typescript" "tsx" "prettier" "eslint" "@typescript-eslint/cli")
        for package in "${global_packages[@]}"; do
            if ! npm list -g "$package" >/dev/null 2>&1; then
                log_info "Installing $package globally..."
                npm install -g "$package"
            fi
        done
    fi
}

setup_backend_development_tools() {
    log_info "Setting up backend development tools..."

    # Setup Python development
    if command_exists python3; then
        if ! command_exists pip; then
            log_info "Installing pip..."
            python3 -m ensurepip --upgrade
        fi

        # Install common Python packages
        local python_packages=("virtualenv" "pipenv" "black" "flake8" "mypy")
        for package in "${python_packages[@]}"; do
            if ! python3 -m pip show "$package" >/dev/null 2>&1; then
                log_info "Installing Python package: $package"
                python3 -m pip install --user "$package"
            fi
        done
    fi
}

setup_data_science_tools() {
    log_info "Setting up data science tools..."

    if command_exists python3; then
        # Install Jupyter and data science packages
        local ds_packages=("jupyterlab" "pandas" "numpy" "matplotlib" "seaborn" "scikit-learn")
        for package in "${ds_packages[@]}"; do
            if ! python3 -m pip show "$package" >/dev/null 2>&1; then
                log_info "Installing data science package: $package"
                python3 -m pip install --user "$package"
            fi
        done
    fi
}

setup_devops_tools() {
    log_info "Setting up DevOps tools..."

    # Install additional DevOps tools
    local devops_tools=("k9s" "stern" "terraform-ls" "tflint")
    for tool in "${devops_tools[@]}"; do
        if ! command_exists "$tool"; then
            log_info "Installing $tool..."
            case $(detect_platform) in
                "macos") brew install "$tool" ;;
                *) log_warn "$tool installation not automated for this platform" ;;
            esac
        fi
    done
}

# Finalization and validation
finalize_installation() {
    section "Finalizing Installation"

    # Run configuration validation
    if [[ -x "$SCRIPT_DIR/health/validate-config.sh" ]]; then
        log_info "Validating configuration files..."
        if "$SCRIPT_DIR/health/validate-config.sh" >/dev/null 2>&1; then
            status_ok "Configuration validation passed"
        else
            status_warn "Configuration validation found some issues"
        fi
    fi

    # Run health check
    if [[ -x "$SCRIPT_DIR/health/health-check.sh" ]]; then
        log_info "Running system health check..."
        "$SCRIPT_DIR/health/health-check.sh" | tail -10
    fi

    # Generate installation summary
    generate_installation_summary
}

generate_installation_summary() {
    cat > "$BACKUP_DIR/installation_summary.txt" << EOF
Dotfiles Installation Summary
============================
Installation Date: $(date)
Platform: $(detect_platform)
Development Environment: $DEVELOPMENT_ENVIRONMENT
Shell: $(detect_shell)

Installed Components:
- Shell Environment: ✅
- Dotfiles Configuration: ✅
EOF

    if [[ "$WITH_VIM" == "true" ]]; then
        echo "- Vim Configuration: ✅" >> "$BACKUP_DIR/installation_summary.txt"
    fi

    if [[ "$WITH_TMUX" == "true" ]]; then
        echo "- Tmux Configuration: ✅" >> "$BACKUP_DIR/installation_summary.txt"
    fi

    echo "" >> "$BACKUP_DIR/installation_summary.txt"
    echo "Log file: $INSTALL_LOG" >> "$BACKUP_DIR/installation_summary.txt"
    echo "Backup directory: $BACKUP_DIR" >> "$BACKUP_DIR/installation_summary.txt"
}

# Main installation flow
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                export LOG_LEVEL=$DEBUG
                shift
                ;;
            -y|--yes)
                AUTO_MODE=true
                shift
                ;;
            --with-vim)
                WITH_VIM=true
                shift
                ;;
            --with-tmux)
                WITH_TMUX=true
                shift
                ;;
            --parallel)
                PARALLEL=true
                shift
                ;;
            --env)
                DEVELOPMENT_ENVIRONMENT="$2"
                shift 2
                ;;
            --no-interactive)
                INTERACTIVE_MODE=false
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Start installation
    show_banner

    # Create backup directory and log file
    ensure_dir "$BACKUP_DIR"
    exec 1> >(tee -a "$INSTALL_LOG")
    exec 2>&1

    # Installation steps
    log_info "Starting enhanced dotfiles installation..."

    detect_system_info || {
        log_error "System requirements not met"
        exit 1
    }

    select_development_environment

    # Backup existing configurations
    if [[ "$AUTO_MODE" != "true" ]]; then
        backup_configurations true
    fi

    install_system_packages
    setup_shell_environment
    setup_development_tools
    finalize_installation

    # Success message
    echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    Installation Complete!                   ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${NC}"

    log_info "Environment: $DEVELOPMENT_ENVIRONMENT"
    log_info "Log file: $INSTALL_LOG"
    log_info "Backup directory: $BACKUP_DIR"

    echo -e "\n${WHITE}Next Steps:${NC}"
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. Run 'dotfile-manager doctor' to check system health"
    echo "3. Run 'dotfile-manager status' to see configuration status"
    echo "4. Customize your environment as needed"

    if [[ "$DEVELOPMENT_ENVIRONMENT" != "minimal" ]]; then
        echo -e "\n${YELLOW}Note: Some tools may require additional setup or manual configuration.${NC}"
        echo "Check the installation log for details: $INSTALL_LOG"
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi