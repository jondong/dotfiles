#!/bin/bash

# Validation script for Web Development Template
# Verifies that all components are properly installed and configured

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/common/utils.sh"

# Validation counters
VALIDATIONS_PASSED=0
VALIDATIONS_FAILED=0
VALIDATIONS_WARNED=0

# Validation functions
validate_nodejs() {
    section "Validating Node.js Installation"

    if command_exists node; then
        local node_version=$(node --version)
        local major_version=$(echo "$node_version" | sed 's/v//' | cut -d. -f1)

        if [[ $major_version -ge 18 ]]; then
            status_ok "Node.js version: $node_version (>= 18.x)"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Node.js version: $node_version (recommend >= 18.x)"
            ((VALIDATIONS_WARNED++))
        fi
    else
        status_error "Node.js not installed"
        ((VALIDATIONS_FAILED++))
    fi
}

validate_npm() {
    section "Validating npm Installation"

    if command_exists npm; then
        local npm_version=$(npm --version)
        status_ok "npm version: $npm_version"

        # Check npm configuration
        if npm config get cache >/dev/null; then
            status_ok "npm configuration is valid"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "npm configuration may be incomplete"
            ((VALIDATIONS_WARNED++))
        fi
    else
        status_error "npm not installed"
        ((VALIDATIONS_FAILED++))
    fi
}

validate_global_packages() {
    section "Validating Global npm Packages"

    local required_packages=(
        "typescript"
        "tsx"
        "ts-node"
        "nodemon"
        "pm2"
        "eslint"
        "prettier"
    )

    local missing_packages=()

    for package in "${required_packages[@]}"; do
        if npm list -g "$package" >/dev/null 2>&1; then
            local version=$(npm list -g "$package" --depth=0 2>/dev/null | grep "$package" | sed 's/.*@//')
            status_ok "$package@$version"
            ((VALIDATIONS_PASSED++))
        else
            status_error "$package not installed globally"
            ((VALIDATIONS_FAILED++))
            missing_packages+=("$package")
        fi
    done

    # Check framework CLIs
    section "Validating Framework CLIs"

    local framework_packages=(
        "create-react-app"
        "@vue/cli"
        "angular-cli"
        "next"
    )

    for package in "${framework_packages[@]}"; do
        if npm list -g "$package" >/dev/null 2>&1; then
            status_ok "$package"
            ((VALIDATIONS_PASSED++))
        else
            log_info "$package not installed globally (optional)"
        fi
    done
}

validate_dev_directories() {
    section "Validating Development Directories"

    local required_dirs=(
        "$HOME/Projects"
        "$HOME/Projects/web"
        "$HOME/Projects/api"
        "$HOME/Sandbox"
    )

    for dir in "${required_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            status_ok "Directory exists: $(basename "$dir")"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Directory missing: $(basename "$dir")"
            ((VALIDATIONS_WARNED++))
        fi
    done
}

validate_environment_variables() {
    section "Validating Environment Variables"

    local required_vars=(
        "NODE_ENV"
        "PATH"
    )

    for var in "${required_vars[@]}"; do
        if [[ -n "${!var:-}" ]]; then
            status_ok "$var is set"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "$var is not set"
            ((VALIDATIONS_WARNED++))
        fi
    done

    # Check PATH for Node.js tools
    if echo "$PATH" | grep -q "node_modules\|npm-global\|yarn-global"; then
        status_ok "PATH includes Node.js global packages"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "PATH may not include Node.js global packages"
        ((VALIDATIONS_WARNED++))
    fi
}

validate_database_tools() {
    section "Validating Database Tools"

    # Check PostgreSQL client
    if command_exists psql; then
        local psql_version=$(psql --version 2>/dev/null | head -1)
        status_ok "PostgreSQL client: $psql_version"
        ((VALIDATIONS_PASSED++))
    else
        log_info "PostgreSQL client not installed (optional)"
    fi

    # Check Redis client
    if command_exists redis-cli; then
        local redis_version=$(redis-cli --version 2>/dev/null)
        status_ok "Redis client: $redis_version"
        ((VALIDATIONS_PASSED++))
    else
        log_info "Redis client not installed (optional)"
    fi

    # Check MongoDB client
    if command_exists mongo || command_exists mongosh; then
        if command_exists mongosh; then
            local mongo_version=$(mongosh --version 2>/dev/null | head -1)
        else
            local mongo_version=$(mongo --version 2>/dev/null | head -1)
        fi
        status_ok "MongoDB client: $mongo_version"
        ((VALIDATIONS_PASSED++))
    else
        log_info "MongoDB client not installed (optional)"
    fi
}

validate_browsers() {
    section "Validating Web Browsers"

    # Check Chrome
    if command_exists google-chrome || command_exists chrome; then
        status_ok "Google Chrome installed"
        ((VALIDATIONS_PASSED++))
    else
        log_info "Google Chrome not found (install recommended)"
    fi

    # Check Firefox
    if command_exists firefox; then
        status_ok "Firefox installed"
        ((VALIDATIONS_PASSED++))
    else
        log_info "Firefox not found (install recommended)"
    fi
}

validate_docker() {
    section "Validating Docker Environment"

    if command_exists docker; then
        local docker_version=$(docker --version 2>/dev/null)
        status_ok "Docker: $docker_version"

        # Check if Docker daemon is running
        if docker info >/dev/null 2>&1; then
            status_ok "Docker daemon is running"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Docker daemon is not running"
            ((VALIDATIONS_WARNED++))
        fi
    else
        log_info "Docker not installed (optional for web development)"
    fi

    if command_exists docker-compose; then
        local compose_version=$(docker-compose --version 2>/dev/null)
        status_ok "Docker Compose: $compose_version"
        ((VALIDATIONS_PASSED++))
    else
        log_info "Docker Compose not installed (optional)"
    fi
}

validate_vscode() {
    section "Validating VS Code Installation"

    if command_exists code; then
        local code_version=$(code --version 2>/dev/null | head -1)
        status_ok "VS Code: $code_version"

        # Check if VS Code is properly configured
        local vscode_settings=""
        local vscode_dir="$HOME/Library/Application Support/Code/User"
        if [[ ! -d "$vscode_dir" ]]; then
            vscode_dir="$HOME/.config/Code/User"
        fi

        if [[ -f "$vscode_dir/settings.json" ]]; then
            status_ok "VS Code settings found"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "VS Code settings not found"
            ((VALIDATIONS_WARNED++))
        fi
    else
        log_info "VS Code not installed (optional)"
    fi
}

validate_git_configuration() {
    section "Validating Git Configuration"

    if command_exists git; then
        local git_version=$(git --version)
        status_ok "Git: $git_version"

        # Check essential git configuration
        if git config --global user.name >/dev/null; then
            status_ok "Git user.name configured"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Git user.name not configured"
            ((VALIDATIONS_WARNED++))
        fi

        if git config --global user.email >/dev/null; then
            status_ok "Git user.email configured"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Git user.email not configured"
            ((VALIDATIONS_WARNED++))
        fi
    else
        status_error "Git not installed"
        ((VALIDATIONS_FAILED++))
    fi
}

validate_performance() {
    section "Validating Performance"

    # Check Node.js performance
    if command_exists node; then
        local startup_time=$(time_command node -e "console.log('test')" 2>/dev/null)
        if (( $(echo "$startup_time < 0.5" | bc -l) )); then
            status_ok "Node.js startup time: ${startup_time}s"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Node.js startup time: ${startup_time}s (slow)"
            ((VALIDATIONS_WARNED++))
        fi
    fi

    # Check npm performance
    if command_exists npm; then
        local npm_help_time=$(time_command npm --help >/dev/null 2>&1)
        if (( $(echo "$npm_help_time < 2.0" | bc -l) )); then
            status_ok "npm response time: ${npm_help_time}s"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "npm response time: ${npm_help_time}s (slow)"
            ((VALIDATIONS_WARNED++))
        fi
    fi
}

# Print validation summary
print_validation_summary() {
    echo -e "\n${WHITE}=== Web Development Environment Validation Summary ===${NC}"
    echo "Total validations: $((VALIDATIONS_PASSED + VALIDATIONS_WARNED + VALIDATIONS_FAILED))"
    echo -e "  ${GREEN}Passed: $VALIDATIONS_PASSED${NC}"
    echo -e "  ${YELLOW}Warnings: $VALIDATIONS_WARNED${NC}"
    echo -e "  ${RED}Failed: $VALIDATIONS_FAILED${NC}"

    if [[ $VALIDATIONS_FAILED -eq 0 ]]; then
        if [[ $VALIDATIONS_WARNED -eq 0 ]]; then
            echo -e "\n${GREEN}🎉 All validations passed! Your web development environment is ready.${NC}"
        else
            echo -e "\n${YELLOW}⚠ Environment is functional but has some warnings.${NC}"
            echo "Consider addressing the warnings for optimal experience."
        fi
        return 0
    else
        echo -e "\n${RED}❌ Critical issues found! Please address the failed validations.${NC}"
        echo "Run the setup script again or manually install missing components."
        return 1
    fi
}

# Main validation function
main() {
    section "Web Development Environment Validation"
    log_info "Checking that all components are properly installed and configured..."

    # Run all validations
    validate_nodejs
    validate_npm
    validate_global_packages
    validate_dev_directories
    validate_environment_variables
    validate_database_tools
    validate_browsers
    validate_docker
    validate_vscode
    validate_git_configuration
    validate_performance

    # Print summary
    print_validation_summary
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi