#!/bin/bash

# Validation script for Backend Development Template
# Verifies that all backend development tools and runtimes are properly installed

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/common/utils.sh"

# Validation counters
VALIDATIONS_PASSED=0
VALIDATIONS_FAILED=0
VALIDATIONS_WARNED=0

# Validation functions
validate_nodejs_environment() {
    section "Validating Node.js Environment"

    # Check Node.js installation
    if command_exists node; then
        local node_version=$(node --version)
        status_ok "Node.js: $node_version"
        ((VALIDATIONS_PASSED++))

        # Check Node.js version
        local major_version=$(echo "$node_version" | sed 's/v//' | cut -d. -f1)
        if [[ $major_version -ge 16 ]]; then
            status_ok "Node.js version >= 16.x (recommended for backend)"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Node.js version < 16.x (upgrade recommended)"
            ((VALIDATIONS_WARNED++))
        fi
    else
        status_error "Node.js not installed"
        ((VALIDATIONS_FAILED++))
    fi

    # Check npm installation
    if command_exists npm; then
        local npm_version=$(npm --version)
        status_ok "npm: $npm_version"
        ((VALIDATIONS_PASSED++))
    else
        status_error "npm not installed"
        ((VALIDATIONS_FAILED++))
    fi

    # Check NVM installation
    if [[ -d "$HOME/.nvm" ]]; then
        status_ok "NVM installed"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "NVM not installed (version management limited)"
        ((VALIDATIONS_WARNED++))
    fi

    # Check global npm packages
    local global_packages=("typescript" "nodemon" "pm2" "express")
    for package in "${global_packages[@]}"; do
        if npm list -g "$package" >/dev/null 2>&1; then
            local version=$(npm list -g "$package" --depth=0 2>/dev/null | grep "$package" | sed 's/.*@//')
            status_ok "Global package: $package@$version"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Global package not installed: $package"
            ((VALIDATIONS_WARNED++))
        fi
    done
}

validate_python_environment() {
    section "Validating Python Environment"

    # Check Python installation
    if command_exists python3.11 || command_exists python3.10 || command_exists python3; then
        local python_cmd=$(command -v python3.11 || command -v python3.10 || command -v python3)
        local python_version=$("$python_cmd" --version 2>&1)
        status_ok "Python: $python_version"
        ((VALIDATIONS_PASSED++))

        # Check Python version
        local major_version=$(echo "$python_version" | sed 's/.*Python \([0-9]*\).*/\1/')
        if [[ $major_version -ge 3 ]]; then
            local minor_version=$(echo "$python_version" | sed 's/.*Python [0-9]*\.\([0-9]*\).*/\1/')
            if [[ $minor_version -ge 8 ]]; then
                status_ok "Python version >= 3.8 (recommended for backend)"
                ((VALIDATIONS_PASSED++))
            else
                status_warn "Python version < 3.8 (upgrade recommended)"
                ((VALIDATIONS_WARNED++))
            fi
        else
            status_error "Python version < 3.x"
            ((VALIDATIONS_FAILED++))
        fi
    else
        status_error "Python not installed"
        ((VALIDATIONS_FAILED++))
    fi

    # Check virtual environment
    if [[ -d "$HOME/.venvs/backend" ]]; then
        status_ok "Backend virtual environment exists"
        ((VALIDATIONS_PASSED++))

        # Check key Python packages in virtual environment
        source "$HOME/.venvs/backend/bin/activate"
        local python_packages=("fastapi" "uvicorn" "django" "flask" "sqlalchemy")
        for package in "${python_packages[@]}"; do
            if python -c "import $package" 2>/dev/null; then
                status_ok "Python package: $package"
                ((VALIDATIONS_PASSED++))
            else
                status_warn "Python package not installed: $package"
                ((VALIDATIONS_WARNED++))
            fi
        done
        deactivate
    else
        status_warn "Backend virtual environment not found"
        ((VALIDATIONS_WARNED++))
    fi
}

validate_go_environment() {
    section "Validating Go Environment"

    # Check Go installation
    if command_exists go; then
        local go_version=$(go version)
        status_ok "Go: $go_version"
        ((VALIDATIONS_PASSED++))

        # Check Go version
        local version_number=$(echo "$go_version" | sed 's/.*go\([0-9]*\.[0-9]*\).*/\1/')
        local major_version=$(echo "$version_number" | cut -d. -f1)
        if [[ $major_version -ge 1 ]]; then
            local minor_version=$(echo "$version_number" | cut -d. -f2)
            if [[ $minor_version -ge 19 ]]; then
                status_ok "Go version >= 1.19 (recommended)"
                ((VALIDATIONS_PASSED++))
            else
                status_warn "Go version < 1.19 (upgrade recommended)"
                ((VALIDATIONS_WARNED++))
            fi
        fi

        # Check Go workspace
        if [[ -d "$HOME/go" ]]; then
            status_ok "Go workspace configured"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Go workspace not configured"
            ((VALIDATIONS_WARNED++))
        fi

        # Check Go tools
        local go_tools=("goimports" "golangci-lint" "air")
        for tool in "${go_tools[@]}"; do
            if command_exists "$tool"; then
                status_ok "Go tool: $tool"
                ((VALIDATIONS_PASSED++))
            else
                status_warn "Go tool not installed: $tool"
                ((VALIDATIONS_WARNED++))
            fi
        done
    else
        status_error "Go not installed"
        ((VALIDATIONS_FAILED++))
    fi
}

validate_java_environment() {
    section "Validating Java Environment"

    # Check Java installation
    if command_exists java; then
        local java_version=$(java -version 2>&1 | head -1)
        status_ok "Java: $java_version"
        ((VALIDATIONS_PASSED++))

        # Check JDK tools
        if command_exists javac; then
            status_ok "Javac compiler available"
            ((VALIDATIONS_PASSED++))
        else
            status_error "Javac compiler not found"
            ((VALIDATIONS_FAILED++))
        fi

        # Check Maven
        if command_exists mvn; then
            local maven_version=$(mvn --version | head -1)
            status_ok "Maven: $maven_version"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Maven not installed"
            ((VALIDATIONS_WARNED++))
        fi

        # Check Gradle
        if command_exists gradle; then
            local gradle_version=$(gradle --version | grep "Gradle" | head -1)
            status_ok "Gradle: $gradle_version"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Gradle not installed"
            ((VALIDATIONS_WARNED++))
        fi
    else
        status_warn "Java not installed (optional for backend)"
        ((VALIDATIONS_WARNED++))
    fi
}

validate_rust_environment() {
    section "Validating Rust Environment"

    # Check Rust installation
    if command_exists rustc; then
        local rust_version=$(rustc --version)
        status_ok "Rust: $rust_version"
        ((VALIDATIONS_PASSED++))

        # Check Cargo
        if command_exists cargo; then
            local cargo_version=$(cargo --version)
            status_ok "Cargo: $cargo_version"
            ((VALIDATIONS_PASSED++))

            # Check Rust tools
            local rust_tools=("rustfmt" "clippy")
            for tool in "${rust_tools[@]}"; do
                if cargo "$tool" --version >/dev/null 2>&1; then
                    status_ok "Rust tool: $tool"
                    ((VALIDATIONS_PASSED++))
                else
                    status_warn "Rust tool not available: $tool"
                    ((VALIDATIONS_WARNED++))
                fi
            done
        else
            status_error "Cargo not found"
            ((VALIDATIONS_FAILED++))
        fi
    else
        status_warn "Rust not installed (optional for backend)"
        ((VALIDATIONS_WARNED++))
    fi
}

validate_databases() {
    section "Validating Database Tools"

    # Check PostgreSQL
    if command_exists psql; then
        local psql_version=$(psql --version 2>/dev/null | head -1)
        status_ok "PostgreSQL client: $psql_version"
        ((VALIDATIONS_PASSED++))

        # Check if PostgreSQL server is running
        if pgrep postgres > /dev/null; then
            status_ok "PostgreSQL server is running"
            ((VALIDATIONS_PASSED++))

            # Test database connection
            if psql -h localhost -U postgres -c "SELECT 1;" >/dev/null 2>&1; then
                status_ok "PostgreSQL connection successful"
                ((VALIDATIONS_PASSED++))
            else
                status_warn "PostgreSQL connection failed"
                ((VALIDATIONS_WARNED++))
            fi
        else
            status_warn "PostgreSQL server is not running"
            ((VALIDATIONS_WARNED++))
        fi
    else
        status_warn "PostgreSQL client not installed"
        ((VALIDATIONS_WARNED++))
    fi

    # Check Redis
    if command_exists redis-cli; then
        local redis_version=$(redis-cli --version 2>/dev/null)
        status_ok "Redis client: $redis_version"
        ((VALIDATIONS_PASSED++))

        # Check if Redis server is running
        if pgrep redis-server > /dev/null; then
            status_ok "Redis server is running"
            ((VALIDATIONS_PASSED++))

            # Test Redis connection
            if redis-cli ping >/dev/null 2>&1; then
                status_ok "Redis connection successful"
                ((VALIDATIONS_PASSED++))
            else
                status_warn "Redis connection failed"
                ((VALIDATIONS_WARNED++))
            fi
        else
            status_warn "Redis server is not running"
            ((VALIDATIONS_WARNED++))
        fi
    else
        status_warn "Redis client not installed"
        ((VALIDATIONS_WARNED++))
    fi

    # Check MongoDB
    if command_exists mongo || command_exists mongosh; then
        if command_exists mongosh; then
            local mongo_version=$(mongosh --version 2>/dev/null | head -1)
        else
            local mongo_version=$(mongo --version 2>/dev/null | head -1)
        fi
        status_ok "MongoDB client: $mongo_version"
        ((VALIDATIONS_PASSED++))

        # Check if MongoDB server is running
        if pgrep mongod > /dev/null; then
            status_ok "MongoDB server is running"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "MongoDB server is not running"
            ((VALIDATIONS_WARNED++))
        fi
    else
        status_warn "MongoDB client not installed"
        ((VALIDATIONS_WARNED++))
    fi

    # Check MySQL
    if command_exists mysql; then
        local mysql_version=$(mysql --version 2>/dev/null)
        status_ok "MySQL client: $mysql_version"
        ((VALIDATIONS_PASSED++))

        # Check if MySQL server is running
        if pgrep mysqld > /dev/null; then
            status_ok "MySQL server is running"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "MySQL server is not running"
            ((VALIDATIONS_WARNED++))
        fi
    else
        status_warn "MySQL client not installed"
        ((VALIDATIONS_WARNED++))
    fi
}

validate_container_tools() {
    section "Validating Container and Orchestration Tools"

    # Check Docker
    if command_exists docker; then
        local docker_version=$(docker --version 2>/dev/null)
        status_ok "Docker: $docker_version"
        ((VALIDATIONS_PASSED++))

        # Check if Docker daemon is running
        if docker info >/dev/null 2>&1; then
            status_ok "Docker daemon is running"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Docker daemon is not running"
            ((VALIDATIONS_WARNED++))
        fi
    else
        status_warn "Docker not installed (optional)"
        ((VALIDATIONS_WARNED++))
    fi

    # Check Docker Compose
    if command_exists docker-compose; then
        local compose_version=$(docker-compose --version 2>/dev/null)
        status_ok "Docker Compose: $compose_version"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "Docker Compose not installed (optional)"
        ((VALIDATIONS_WARNED++))
    fi

    # Check Kubernetes
    if command_exists kubectl; then
        local kubectl_version=$(kubectl version --client --short 2>/dev/null)
        status_ok "kubectl: $kubectl_version"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "kubectl not installed (optional)"
        ((VALIDATIONS_WARNED++))
    fi

    # Check Helm
    if command_exists helm; then
        local helm_version=$(helm version --short 2>/dev/null)
        status_ok "Helm: $helm_version"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "Helm not installed (optional)"
        ((VALIDATIONS_WARNED++))
    fi
}

validate_message_queues() {
    section "Validating Message Queue Systems"

    # Check RabbitMQ
    if command_exists rabbitmqctl; then
        status_ok "RabbitMQ tools available"
        ((VALIDATIONS_PASSED++))

        # Check if RabbitMQ server is running
        if pgrep beam.smp > /dev/null || pgrep rabbitmq > /dev/null; then
            status_ok "RabbitMQ server is running"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "RabbitMQ server is not running"
            ((VALIDATIONS_WARNED++))
        fi
    else
        status_warn "RabbitMQ tools not installed"
        ((VALIDATIONS_WARNED++))
    fi

    # Check Kafka
    if [[ -d "/opt/homebrew/opt/kafka" ]] || [[ -d "/usr/local/opt/kafka" ]] || [[ -d "/opt/kafka" ]]; then
        status_ok "Kafka installation found"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "Kafka not installed (optional)"
        ((VALIDATIONS_WARNED++))
    fi
}

validate_development_tools() {
    section "Validating Development Tools"

    # Check Git
    if command_exists git; then
        local git_version=$(git --version)
        status_ok "Git: $git_version"
        ((VALIDATIONS_PASSED++))
    else
        status_error "Git not installed"
        ((VALIDATIONS_FAILED++))
    fi

    # Check VS Code
    if command_exists code; then
        local code_version=$(code --version 2>/dev/null | head -1)
        status_ok "VS Code: $code_version"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "VS Code not installed (optional)"
        ((VALIDATIONS_WARNED++))
    fi

    # Check API testing tools
    if command_exists http; then
        status_ok "HTTPie installed"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "HTTPie not installed"
        ((VALIDATIONS_WARNED++))
    fi

    # Check Postman (GUI application)
    if command_exists postman || [[ -d "/Applications/Postman.app" ]]; then
        status_ok "Postman available"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "Postman not installed"
        ((VALIDATIONS_WARNED++))
    fi

    # Check common tools
    local common_tools=("curl" "wget" "jq" "yq")
    for tool in "${common_tools[@]}"; do
        if command_exists "$tool"; then
            status_ok "Tool available: $tool"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Tool not available: $tool"
            ((VALIDATIONS_WARNED++))
        fi
    done
}

validate_project_structure() {
    section "Validating Project Structure"

    local required_dirs=(
        "$HOME/Projects/backend"
        "$HOME/Projects/backend/apis"
        "$HOME/Projects/backend/services"
        "$HOME/Projects/backend/microservices"
        "$HOME/Projects/backend/databases"
        "$HOME/Projects/backend/deployments"
        "$HOME/Projects/backend/monitoring"
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

    # Check README
    if [[ -f "$HOME/Projects/backend/README.md" ]]; then
        status_ok "README.md found in project directory"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "README.md not found in project directory"
        ((VALIDATIONS_WARNED++))
    fi

    # Check .gitignore
    if [[ -f "$HOME/Projects/backend/.gitignore" ]]; then
        status_ok ".gitignore found in project directory"
        ((VALIDATIONS_PASSED++))
    else
        status_warn ".gitignore not found in project directory"
        ((VALIDATIONS_WARNED++))
    fi

    # Check example projects
    local example_dirs=(
        "$HOME/Projects/backend/apis/example-node-api"
        "$HOME/Projects/backend/apis/example-python-api"
        "$HOME/Projects/backend/apis/example-go-api"
    )

    for dir in "${example_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            status_ok "Example project exists: $(basename "$dir")"
            ((VALIDATIONS_PASSED++))
        else
            status_info "Example project not created: $(basename "$dir")"
        fi
    done
}

validate_environment_variables() {
    section "Validating Environment Variables"

    local required_vars=(
        "BACKEND_HOME"
        "APIS_DIR"
        "DATABASE_URL"
        "REDIS_URL"
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

    # Check PATH includes development tools
    if echo "$PATH" | grep -q "npm-global\|go\|cargo"; then
        status_ok "PATH includes backend development tools"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "PATH may not include all backend development tools"
        ((VALIDATIONS_WARNED++))
    fi

    # Check virtual environment in PATH
    if echo "$PATH" | grep -q ".venvs/backend"; then
        status_ok "Python virtual environment in PATH"
        ((VALIDATIONS_PASSED++))
    else
        status_info "Python virtual environment not activated"
    fi
}

validate_performance() {
    section "Validating Performance"

    # Check available memory
    if command_exists free; then
        local total_mem=$(free -m | awk 'NR==2{printf "%.0f", $2/1024}')
        if [[ $total_mem -ge 8 ]]; then
            status_ok "Available memory: ${total_mem}GB (>= 8GB recommended for backend)"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Available memory: ${total_mem}GB (8GB+ recommended)"
            ((VALIDATIONS_WARNED++))
        fi
    fi

    # Check CPU cores
    local cpu_cores=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null)
    if [[ $cpu_cores -ge 4 ]]; then
        status_ok "CPU cores: $cpu_cores (>= 4 recommended)"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "CPU cores: $cpu_cores (4+ recommended)"
        ((VALIDATIONS_WARNED++))
    fi

    # Check available disk space
    local backend_dir="$HOME/Projects/backend"
    if [[ -d "$backend_dir" ]]; then
        local available_space=$(df -h "$backend_dir" | awk 'NR==2 {print $4}')
        status_ok "Available disk space: $available_space"
        ((VALIDATIONS_PASSED++))
    fi

    # Test startup performance
    if command_exists node; then
        local node_startup_time=$(time_command node -e "console.log('test')" 2>/dev/null)
        if (( $(echo "$node_startup_time < 0.5" | bc -l) )); then
            status_ok "Node.js startup time: ${node_startup_time}s"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Node.js startup time: ${node_startup_time}s (slow)"
            ((VALIDATIONS_WARNED++))
        fi
    fi

    if command_exists python3; then
        local python_startup_time=$(time_command python3 -c "print('test')" 2>/dev/null)
        if (( $(echo "$python_startup_time < 0.5" | bc -l) )); then
            status_ok "Python startup time: ${python_startup_time}s"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Python startup time: ${python_startup_time}s (slow)"
            ((VALIDATIONS_WARNED++))
        fi
    fi
}

# Print validation summary
print_validation_summary() {
    echo -e "\n${WHITE}=== Backend Development Environment Validation Summary ===${NC}"
    echo "Total validations: $((VALIDATIONS_PASSED + VALIDATIONS_WARNED + VALIDATIONS_FAILED))"
    echo -e "  ${GREEN}Passed: $VALIDATIONS_PASSED${NC}"
    echo -e "  ${YELLOW}Warnings: $VALIDATIONS_WARNED${NC}"
    echo -e "  ${RED}Failed: $VALIDATIONS_FAILED${NC}"

    if [[ $VALIDATIONS_FAILED -eq 0 ]]; then
        if [[ $VALIDATIONS_WARNED -eq 0 ]]; then
            echo -e "\n${GREEN}🎉 All validations passed! Your backend development environment is ready.${NC}"
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
    section "Backend Development Environment Validation"
    log_info "Checking that all backend development components are properly installed and configured..."

    # Run all validations
    validate_nodejs_environment
    validate_python_environment
    validate_go_environment
    validate_java_environment
    validate_rust_environment
    validate_databases
    validate_container_tools
    validate_message_queues
    validate_development_tools
    validate_project_structure
    validate_environment_variables
    validate_performance

    # Print summary
    print_validation_summary
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi