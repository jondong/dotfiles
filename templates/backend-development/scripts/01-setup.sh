#!/bin/bash

# Setup script for Backend Development Template
# Installs and configures backend development tools and runtimes

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/common/utils.sh"

main() {
    section "Setting Up Backend Development Environment"

    # Install system packages
    install_system_packages

    # Setup Node.js environment
    setup_nodejs_environment

    # Setup Python environment
    setup_python_environment

    # Setup Go environment
    setup_go_environment

    # Setup Java environment
    setup_java_environment

    # Setup Rust environment
    setup_rust_environment

    # Setup databases
    setup_databases

    # Setup message queues
    setup_message_queues

    # Setup container tools
    setup_container_tools

    # Setup API testing tools
    setup_api_testing_tools

    # Setup VS Code extensions
    if command_exists code; then
        setup_vscode_extensions
    fi

    # Create project structure
    create_project_structure

    # Configure environment
    configure_environment

    log_success "Backend development environment setup complete!"
}

install_system_packages() {
    log_info "Installing system packages..."

    local platform=$(detect_platform)

    case "$platform" in
        "macos")
            install_macos_packages
            ;;
        "linux")
            install_linux_packages
            ;;
    esac
}

install_macos_packages() {
    if ! command_exists brew; then
        log_error "Homebrew not found. Please install it first."
        return 1
    fi

    # Programming language runtimes
    local runtime_packages=(
        "node"
        "python@3.11"
        "go"
        "openjdk"
        "rust"
        "ruby"
    )

    for package in "${runtime_packages[@]}"; do
        if brew list "$package" >/dev/null 2>&1; then
            log_info "$package already installed"
        else
            log_info "Installing $package..."
            brew install "$package"
        fi
    done

    # Database packages
    local database_packages=(
        "postgresql"
        "mongodb-community"
        "redis"
        "mysql"
    )

    for package in "${database_packages[@]}"; do
        if brew list "$package" >/dev/null 2>&1; then
            log_info "$package already installed"
        else
            log_info "Installing $package..."
            brew install "$package"
        fi
    done

    # Development tools
    local tool_packages=(
        "docker"
        "docker-compose"
        "kubectl"
        "helm"
        "nginx"
        "git"
        "wget"
        "curl"
        "jq"
        "yq"
    )

    for package in "${tool_packages[@]}"; do
        if brew list "$package" >/dev/null 2>&1; then
            log_info "$package already installed"
        else
            log_info "Installing $package..."
            brew install "$package"
        fi
    done

    # Build tools
    local build_packages=(
        "maven"
        "gradle"
        "cmake"
        "make"
    )

    for package in "${build_packages[@]}"; do
        if brew list "$package" >/dev/null 2>&1; then
            log_info "$package already installed"
        else
            log_info "Installing $package..."
            brew install "$package"
        fi
    done

    # Message queues
    local mq_packages=(
        "rabbitmq"
        "kafka"
    )

    for package in "${mq_packages[@]}"; do
        if brew list "$package" >/dev/null 2>&1; then
            log_info "$package already installed"
        else
            log_info "Installing $package..."
            brew install "$package"
        fi
    done

    # GUI applications
    local cask_packages=(
        "postman"
        "insomnia"
        "tableplus"
        "mongoclient"
        "pgadmin"
        "redis-desktop-manager"
        "docker-desktop"
    )

    for package in "${cask_packages[@]}"; do
        if brew list --cask "$package" >/dev/null 2>&1; then
            log_info "$package already installed"
        else
            log_info "Installing $package..."
            brew install --cask "$package"
        fi
    done
}

install_linux_packages() {
    local package_manager=$(detect_package_manager)

    case "$package_manager" in
        "apt")
            sudo apt-get update

            local packages=(
                "nodejs"
                "npm"
                "python3.11"
                "python3-pip"
                "python3-dev"
                "python3-venv"
                "golang-go"
                "openjdk-17-jdk"
                "rustc"
                "cargo"
                "postgresql"
                "postgresql-contrib"
                "mongodb"
                "redis-server"
                "mysql-server"
                "docker.io"
                "docker-compose"
                "kubectl"
                "nginx"
                "git"
                "wget"
                "curl"
                "jq"
                "maven"
                "gradle"
                "build-essential"
                "cmake"
                "make"
                "rabbitmq-server"
            )

            for package in "${packages[@]}"; do
                if dpkg -l | grep -q "^ii.*$package"; then
                    log_info "$package already installed"
                else
                    log_info "Installing $package..."
                    sudo apt-get install -y "$package"
                fi
            done
            ;;
        "yum"|"dnf")
            sudo "$package_manager" groupinstall -y "Development Tools"

            local packages=(
                "nodejs"
                "npm"
                "python3.11"
                "python3-pip"
                "python3-devel"
                "golang"
                "java-17-openjdk"
                "rust"
                "postgresql-server"
                "mongodb"
                "redis"
                "mysql-server"
                "docker"
                "docker-compose"
                "kubectl"
                "nginx"
                "git"
                "wget"
                "curl"
                "jq"
                "maven"
                "gradle"
                "cmake"
                "make"
                "rabbitmq-server"
            )

            for package in "${packages[@]}"; do
                if rpm -q "$package" >/dev/null 2>&1; then
                    log_info "$package already installed"
                else
                    log_info "Installing $package..."
                    sudo "$package_manager" install -y "$package"
                fi
            done
            ;;
    esac
}

setup_nodejs_environment() {
    log_info "Setting up Node.js environment..."

    # Install Node.js version manager if not present
    if [[ ! -d "$HOME/.nvm" ]]; then
        log_info "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    fi

    # Install latest LTS Node.js
    if command_exists nvm; then
        nvm install --lts
        nvm use --lts
        nvm alias default node
    fi

    # Configure npm
    npm config set init-author-name "$USER"
    npm config set init-author-email "$USER@localhost"
    npm config set init-license "MIT"
    npm config set init-version "1.0.0"

    # Create global npm directory
    ensure_dir "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global"

    # Install global Node.js packages
    local npm_packages=(
        "typescript"
        "ts-node"
        "nodemon"
        "pm2"
        "express-generator"
        "nestjs-cli"
        "prisma"
        "npm-check-updates"
        "concurrently"
        "cross-env"
    )

    for package in "${npm_packages[@]}"; do
        if npm list -g "$package" >/dev/null 2>&1; then
            log_info "$package already installed globally"
        else
            log_info "Installing $package globally..."
            npm install -g "$package"
        fi
    done
}

setup_python_environment() {
    log_info "Setting up Python environment..."

    # Create virtual environment
    if [[ ! -d "$HOME/.venvs/backend" ]]; then
        log_info "Creating Python virtual environment..."
        ensure_dir "$HOME/.venvs"
        python3.11 -m venv "$HOME/.venvs/backend"
    fi

    # Activate virtual environment
    source "$HOME/.venvs/backend/bin/activate"

    # Upgrade pip
    pip install --upgrade pip setuptools wheel

    # Install core Python packages
    local python_packages=(
        "fastapi>=0.68.0"
        "uvicorn>=0.15.0"
        "gunicorn>=20.1.0"
        "django>=4.0.0"
        "flask>=2.0.0"
        "pydantic>=1.8.0"
        "sqlalchemy>=1.4.0"
        "alembic>=1.7.0"
        "psycopg2-binary>=2.9.0"
        "pymongo>=4.0.0"
        "redis>=4.1.0"
        "celery>=5.2.0"
        "python-jose>=3.3.0"
        "passlib>=1.7.0"
        "bcrypt>=3.2.0"
        "python-multipart>=0.0.5"
        "requests>=2.27.0"
        "httpx>=0.23.0"
        "aiofiles>=0.8.0"
        "python-dotenv>=0.19.0"
        "pyyaml>=6.0"
        "jinja2>=3.0.0"
        "click>=8.0.0"
        "rich>=12.0.0"
        "typer>=0.4.0"
        "structlog>=22.0.0"
        "loguru>=0.6.0"
        "pytest>=7.0.0"
        "pytest-asyncio>=0.18.0"
        "pytest-cov>=3.0.0"
        "black>=22.0.0"
        "isort>=5.10.0"
        "flake8>=4.0.0"
        "mypy>=0.950"
    )

    for package in "${python_packages[@]}"; do
        log_info "Installing Python package: $package"
        pip install "$package"
    done

    deactivate
}

setup_go_environment() {
    log_info "Setting up Go environment..."

    # Create Go workspace
    ensure_dir "$HOME/go"
    ensure_dir "$HOME/go/bin"
    ensure_dir "$HOME/go/src"
    ensure_dir "$HOME/go/pkg"

    # Install Go tools
    local go_tools=(
        "golang.org/x/tools/cmd/goimports"
        "github.com/golangci/golangci-lint/cmd/golangci-lint"
        "github.com/air-verse/air"
        "github.com/swaggo/swag/cmd/swag"
        "github.com/golang-migrate/migrate"
        "github.com/pressly/goose/v3/cmd/goose"
        "github.com/golang/mock/mockgen"
        "honnef.co/go/tools/cmd/staticcheck"
        "golang.org/x/vuln/cmd/govulncheck"
    )

    for tool in "${go_tools[@]}"; do
        log_info "Installing Go tool: $tool"
        go install "$tool@latest" || log_warn "Failed to install $tool"
    done

    # Install common Go libraries
    mkdir -p "$HOME/go/src/tools"
    cd "$HOME/go/src/tools"

    local go_libs=(
        "github.com/gin-gonic/gin"
        "github.com/gorilla/mux"
        "github.com/labstack/echo/v4"
        "github.com/go-chi/chi/v5"
        "github.com/gofiber/fiber/v2"
        "gorm.io/gorm"
        "github.com/jmoiron/sqlx"
        "github.com/lib/pq"
        "github.com/go-redis/redis/v8"
        "github.com/streadway/amqp"
        "github.com/segmentio/kafka-go"
        "github.com/golang-jwt/jwt/v4"
        "github.com/spf13/viper"
        "github.com/spf13/cobra"
        "github.com/sirupsen/logrus"
        "go.uber.org/zap"
        "github.com/stretchr/testify"
    )

    for lib in "${go_libs[@]}"; do
        log_info "Downloading Go library: $lib"
        go get "$lib" || log_warn "Failed to get $lib"
    done

    cd - >/dev/null
}

setup_java_environment() {
    log_info "Setting up Java environment..."

    # Set JAVA_HOME for macOS
    if [[ "$(uname)" == "Darwin" ]]; then
        export JAVA_HOME=$(/usr/libexec/java_home -v 17)
    fi

    # Create Maven repository directory
    ensure_dir "$HOME/.m2"
    ensure_dir "$HOME/.m2/repository"

    # Create Maven settings.xml
    cat > "$HOME/.m2/settings.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
          http://maven.apache.org/xsd/settings-1.0.0.xsd">
    <localRepository>${user.home}/.m2/repository</localRepository>
    <interactiveMode>true</interactiveMode>
    <offlineMode>false</offlineMode>
</settings>
EOF

    # Create Gradle configuration
    ensure_dir "$HOME/.gradle"
    cat > "$HOME/.gradle/gradle.properties" << 'EOF'
org.gradle.parallel=true
org.gradle.daemon=true
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
org.gradle.caching=true
EOF
}

setup_rust_environment() {
    log_info "Setting up Rust environment..."

    # Install Rust if not present
    if ! command_exists rustc; then
        log_info "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi

    # Install common Rust tools
    local rust_tools=(
        "cargo-watch"
        "cargo-edit"
        "cargo-audit"
        "cargo-deny"
        "cargo-outdated"
        "cargo-expand"
        "rustfmt"
        "clippy"
    )

    for tool in "${rust_tools[@]}"; do
        log_info "Installing Rust tool: $tool"
        cargo install "$tool" || log_warn "Failed to install $tool"
    done

    # Create Rust project template
    mkdir -p "$HOME/.cargo"
    cat >> "$HOME/.cargo/config.toml" << 'EOF'

[build]
rustflags = ["-D", "warnings"]

[net]
git-fetch-with-cli = true
EOF
}

setup_databases() {
    log_info "Setting up databases..."

    local platform=$(detect_platform)

    # Start database services
    case "$platform" in
        "macos")
            if command_exists brew; then
                brew services start postgresql || true
                brew services start redis || true
                brew services start mongodb-community || true
                brew services start mysql || true
            fi
            ;;
        "linux")
            sudo systemctl start postgresql || true
            sudo systemctl start redis-server || true
            sudo systemctl start mongod || true
            sudo systemctl start mysql || true
            ;;
    esac

    # Create development databases
    if command_exists psql; then
        createdb -U postgres backend_dev 2>/dev/null || log_info "Database 'backend_dev' already exists"
        createdb -U postgres backend_test 2>/dev/null || log_info "Database 'backend_test' already exists"
    fi
}

setup_message_queues() {
    log_info "Setting up message queues..."

    local platform=$(detect_platform)

    case "$platform" in
        "macos")
            if command_exists brew; then
                brew services start rabbitmq || true
                # Kafka setup is more complex, just make sure it's available
                if ! brew list kafka >/dev/null 2>&1; then
                    log_info "Kafka not installed, skipping..."
                fi
            fi
            ;;
        "linux")
            sudo systemctl start rabbitmq-server || true
            ;;
    esac
}

setup_container_tools() {
    log_info "Setting up container tools..."

    # Create Docker configuration
    ensure_dir "$HOME/.docker"
    cat > "$HOME/.docker/config.json" << 'EOF'
{
  "experimental": "enabled",
  "debug": false,
  "features": {
    "buildkit": true
  }
}
EOF

    # Create Kubernetes configuration directory
    ensure_dir "$HOME/.kube"

    # Install Helm plugins if Helm is available
    if command_exists helm; then
        helm plugin install https://github.com/databus23/helm-diff || log_warn "Helm diff plugin already installed"
    fi
}

setup_api_testing_tools() {
    log_info "Setting up API testing tools..."

    # Install HTTPie if not present
    if ! command_exists http; then
        log_info "Installing HTTPie..."
        pip install httpie || pip3 install httpie
    fi

    # Create API testing configuration
    ensure_dir "$HOME/.httpie"
    cat > "$HOME/.httpie/config.json" << 'EOF'
{
    "default_options": [
        "--style=auto",
        "--print=Hb",
        "--verify=no"
    ]
}
EOF
}

setup_vscode_extensions() {
    log_info "Installing VS Code extensions for backend development..."

    local extensions=(
        "ms-python.python"
        "ms-python.vscode-pylance"
        "ms-vscode.vscode-typescript-next"
        "esbenp.prettier-vscode"
        "ms-vscode.vscode-eslint"
        "golang.go"
        "ms-vscode.vscode-java"
        "rust-lang.rust-analyzer"
        "redhat.vscode-yaml"
        "ms-kubernetes-tools.vscode-kubernetes-tools"
        "ms-vscode-remote.remote-containers"
        "humao.rest-client"
        "ms-vscode.vscode-docker"
        "formulahendry.code-runner"
        "eamodio.gitlens"
        "ms-vscode.vscode-json"
        "ms-vscode.hexeditor"
    )

    for extension in "${extensions[@]}"; do
        log_info "Installing VS Code extension: $extension"
        code --install-extension "$extension" || log_warn "Failed to install $extension"
    done

    # Create VS Code settings for backend development
    local vscode_dir="$HOME/Library/Application Support/Code/User"
    if [[ ! -d "$vscode_dir" ]]; then
        vscode_dir="$HOME/.config/Code/User"
    fi

    ensure_dir "$vscode_dir"

    cat > "$vscode_dir/settings.json" << 'EOF'
{
    "python.defaultInterpreterPath": "~/.venvs/backend/bin/python",
    "python.terminal.activateEnvironment": true,
    "python.linting.enabled": true,
    "python.linting.flake8Enabled": true,
    "python.formatting.provider": "black",
    "go.useLanguageServer": true,
    "go.lintOnSave": "package",
    "go.vetOnSave": "package",
    "go.buildOnSave": "package",
    "go.lintTool": "golangci-lint",
    "java.home": "/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home",
    "java.configuration.updateBuildConfiguration": "automatic",
    "rust-analyzer.cargo.features": "all",
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    },
    "search.exclude": {
        "**/node_modules": true,
        "**/.git": true,
        "**/target": true,
        "**/build": true,
        "**/dist": true,
        "**/bin": true
    },
    "files.exclude": {
        "**/.git": true,
        "**/.DS_Store": true,
        "**/Thumbs.db": true,
        "**/node_modules": true,
        "**/target": true,
        "**/build": true
    }
}
EOF
}

create_project_structure() {
    log_info "Creating project structure..."

    local base_dir="$HOME/Projects/backend"
    local directories=(
        "$base_dir"
        "$base_dir/apis"
        "$base_dir/services"
        "$base_dir/microservices"
        "$base_dir/databases"
        "$base_dir/deployments"
        "$base_dir/monitoring"
    )

    for dir in "${directories[@]}"; do
        ensure_dir "$dir"
    done

    # Create README files
    cat > "$base_dir/README.md" << 'EOF'
# Backend Development Projects

This directory contains all backend development projects including APIs, services, and microservices.

## Structure

- `apis/` - RESTful and GraphQL APIs
- `services/` - Backend services and applications
- `microservices/` - Microservice architectures
- `databases/` - Database schemas and migrations
- `deployments/` - Docker, Kubernetes, and deployment configurations
- `monitoring/` - Monitoring, logging, and alerting configurations

## Development Environment

- **Node.js**: JavaScript/TypeScript runtime
- **Python**: FastAPI, Django, Flask applications
- **Go**: High-performance services
- **Java**: Spring Boot applications
- **Rust**: Systems programming and performance-critical services

## Getting Started

1. Activate your development environment
2. Navigate to the appropriate project directory
3. Start development servers or run tests
4. Use the provided aliases for common tasks

Happy backend development! 🚀
EOF

    # Create .gitignore for backend projects
    cat > "$base_dir/.gitignore" << 'EOF'
# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
.venv/
.env
.env.local
.env.*.local

# Go
*.exe
*.exe~
*.dll
*.so
*.dylib
*.test
*.out
go.work

# Java
*.class
*.jar
*.war
*.ear
*.zip
*.tar.gz
*.rar
hs_err_pid*
target/
!.mvn/wrapper/maven-wrapper.jar

# Rust
/target/
**/*.rs.bk
Cargo.lock

# Database
*.db
*.sqlite
*.sqlite3

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Docker
.dockerignore

# Build outputs
dist/
build/
bin/
out/

# Logs
logs/
*.log

# Temporary files
tmp/
temp/
EOF

    # Create example API project structure
    mkdir -p "$base_dir/apis/example-node-api"
    mkdir -p "$base_dir/apis/example-python-api"
    mkdir -p "$base_dir/apis/example-go-api"
}

configure_environment() {
    log_info "Configuring environment..."

    # Create environment file template
    cat > "$HOME/.env.backend.template" << 'EOF'
# Backend Development Environment Variables

# Application
NODE_ENV=development
PORT=3000
HOST=localhost

# Database
DATABASE_URL=postgresql://backenddev:backenddev@localhost:5432/backend_dev
REDIS_URL=redis://localhost:6379
MONGODB_URL=mongodb://localhost:27017/backend_dev

# Security
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=24h
BCRYPT_ROUNDS=12

# Message Queues
RABBITMQ_URL=amqp://guest:guest@localhost:5672/
KAFKA_BROKERS=localhost:9092

# External Services
AWS_REGION=us-west-2
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587

# Monitoring
LOG_LEVEL=debug
PROMETHEUS_PORT=9090
GRAFANA_PORT=3001

# Development
DEBUG=true
HOT_RELOAD=true
EOF

    # Create shell configuration for backend development
    cat >> "$HOME/.zshrc" << 'EOF'

# Backend Development Environment
if [[ -f "$HOME/Projects/backend/templates/backend-development/env.sh" ]]; then
    source "$HOME/Projects/backend/templates/backend-development/env.sh"
fi
EOF

    # Configure Git for backend development
    git config --global init.templateDir "$HOME/.git-template"
    mkdir -p "$HOME/.git-template/info"

    cat > "$HOME/.git-template/info/attributes" << 'EOF'
# Git attributes for backend development
*.js linguist-language=JavaScript
*.ts linguist-language=TypeScript
*.go linguist-language=Go
*.java linguist-language=Java
*.rs linguist-language=Rust
*.py linguist-language=Python

# Handle line endings consistently
* text=auto eol=lf
*.sh text eol=lf
*.js text eol=lf
*.ts text eol=lf
*.json text eol=lf
*.yml text eol=lf
*.yaml text eol=lf

# Binary files
*.jpg binary
*.png binary
*.gif binary
*.pdf binary
*.zip binary
*.tar.gz binary
EOF
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi