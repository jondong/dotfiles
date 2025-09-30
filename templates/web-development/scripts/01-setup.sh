#!/bin/bash

# Setup script for Web Development Template
# Installs and configures web development tools

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/common/utils.sh"

main() {
    section "Setting Up Web Development Environment"

    # Check Node.js installation
    if ! command_exists node; then
        log_info "Node.js not found, installing..."
        install_nodejs
    else
        local node_version=$(node --version)
        log_info "Node.js already installed: $node_version"
    fi

    # Setup npm global packages
    setup_npm_globals

    # Configure npm for better performance
    configure_npm

    # Setup code quality tools globally
    setup_code_quality_tools

    # Configure git for web development
    configure_git_webdev

    # Setup local development directories
    setup_dev_directories

    # Install VS Code extensions if available
    if command_exists code; then
        setup_vscode_extensions
    fi

    # Setup database tools
    setup_database_tools

    log_success "Web development environment setup complete!"
}

install_nodejs() {
    local platform=$(detect_platform)

    case "$platform" in
        "macos")
            if command_exists brew; then
                brew install node
            else
                log_error "Homebrew not found. Please install Node.js manually."
                return 1
            fi
            ;;
        "linux")
            case $(detect_package_manager) in
                "apt")
                    # Install Node.js from NodeSource repository
                    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                    sudo apt-get install -y nodejs
                    ;;
                "yum"|"dnf")
                    sudo "$package_manager" install -y nodejs npm
                    ;;
                "pacman")
                    sudo pacman -S --noconfirm nodejs npm
                    ;;
                *)
                    log_error "Package manager not supported for Node.js installation"
                    return 1
                    ;;
            esac
            ;;
        *)
            log_error "Platform not supported for automatic Node.js installation"
            return 1
            ;;
    esac
}

setup_npm_globals() {
    log_info "Installing global npm packages..."

    # Essential web development packages
    local packages=(
        "typescript"
        "tsx"
        "ts-node"
        "nodemon"
        "pm2"
        "http-server"
        "serve"
        "eslint"
        "prettier"
        "npm-check-updates"
        "npkill"
        "ntl"
    )

    for package in "${packages[@]}"; do
        if ! npm list -g "$package" >/dev/null 2>&1; then
            log_info "Installing $package globally..."
            npm install -g "$package"
        else
            log_info "$package already installed globally"
        fi
    done

    # Framework CLIs
    local framework_packages=(
        "create-react-app"
        "@vue/cli"
        "angular-cli"
        "next"
        "nuxt"
    )

    for package in "${framework_packages[@]}"; do
        if ! npm list -g "$package" >/dev/null 2>&1; then
            log_info "Installing $package..."
            npm install -g "$package"
        fi
    done
}

configure_npm() {
    log_info "Configuring npm for better performance..."

    # Set npm configuration
    npm config set init-author-name "$USER"
    npm config set init-author-email "$USER@localhost"
    npm config set init-license "MIT"
    npm config set init-version "1.0.0"

    # Configure npm cache and registry
    npm config set cache "$HOME/.npm-cache"
    npm config set registry "https://registry.npmjs.org/"

    # Enable npm scripts completion
    if command_exists npm; then
        npm completion >> ~/.zshrc 2>/dev/null || true
    fi

    # Create .npmrc with useful configurations
    cat > "$HOME/.npmrc" << 'EOF'
# NPM Configuration
# Increase maximum number of simultaneous connections
maxsockets=50

# Optimize for faster downloads
progress=true
unicode=true

# Save exact versions
save-exact=true

# Audit for security vulnerabilities
audit=true

# Enable npm autocompletion
completion=true

# Custom registry configurations (uncomment if needed)
# @mycompany:registry=https://npm.mycompany.com/
EOF

    log_info "npm configuration completed"
}

setup_code_quality_tools() {
    log_info "Setting up code quality tools..."

    # Install additional linting and formatting tools
    local quality_packages=(
        "commitizen"
        "@commitlint/cli"
        "husky"
        "lint-staged"
    )

    for package in "${quality_packages[@]}"; do
        if ! npm list -g "$package" >/dev/null 2>&1; then
            log_info "Installing $package..."
            npm install -g "$package"
        fi
    done

    # Create global ESLint configuration
    cat > "$HOME/.eslintrc.js" << 'EOF'
module.exports = {
  env: {
    browser: true,
    es2021: true,
    node: true,
  },
  extends: [
    'eslint:recommended',
  ],
  parserOptions: {
    ecmaVersion: 12,
    sourceType: 'module',
  },
  rules: {
    'no-console': 'warn',
    'no-unused-vars': 'warn',
    'prefer-const': 'error',
  },
};
EOF

    # Create global Prettier configuration
    cat > "$HOME/.prettierrc" << 'EOF'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
EOF

    log_info "Code quality tools setup completed"
}

configure_git_webdev() {
    log_info "Configuring Git for web development..."

    # Set up git hooks for web development
    git config --global init.templateDir "$HOME/.git-template"

    # Configure git attributes for web files
    mkdir -p "$HOME/.git-template/info"
    cat > "$HOME/.git-template/info/attributes" << 'EOF'
# Git attributes for web development
*.js linguist-language=JavaScript
*.jsx linguist-language=JavaScript
*.ts linguist-language=TypeScript
*.tsx linguist-language=TypeScript
*.css linguist-language=CSS
*.scss linguist-language=SCSS
*.vue linguist-language=Vue
*.html linguist-language=HTML
*.json linguist-language=JSON

# Handle line endings consistently
* text=auto eol=lf
*.sh text eol=lf
*.js text eol=lf
*.ts text eol=lf
*.json text eol=lf

# Binary files
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.ico binary
*.woff binary
*.woff2 binary
*.ttf binary
*.eot binary
EOF

    log_info "Git configuration for web development completed"
}

setup_dev_directories() {
    log_info "Creating development directories..."

    local dev_dirs=(
        "$HOME/Projects"
        "$HOME/Projects/web"
        "$HOME/Projects/mobile"
        "$HOME/Projects/api"
        "$HOME/Projects/experiments"
        "$HOME/Projects/open-source"
        "$HOME/Projects/clients"
        "$HOME/Sandbox"
        "$HOME/Sandbox/react"
        "$HOME/Sandbox/vue"
        "$HOME/Sandbox/node"
        "$HOME/Sandbox/typescript"
    )

    for dir in "${dev_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log_info "Created directory: $dir"
        fi
    done

    # Create README files for organization
    cat > "$HOME/Projects/README.md" << 'EOF'
# Projects Directory

This directory contains all development projects organized by type:

## Structure

- `web/` - Web applications and websites
- `mobile/` - Mobile applications
- `api/` - Backend APIs and services
- `experiments/` - Experimental projects and prototypes
- `open-source/` - Open source contributions
- `clients/` - Client work and commercial projects

## Getting Started

1. Navigate to the appropriate category
2. Create a new project directory
3. Initialize with the appropriate template
4. Start coding!

Happy coding! 🚀
EOF

    log_info "Development directories setup completed"
}

setup_vscode_extensions() {
    log_info "Installing VS Code extensions for web development..."

    local extensions=(
        "ms-vscode.vscode-typescript-next"
        "bradlc.vscode-tailwindcss"
        "esbenp.prettier-vscode"
        "ms-vscode.vscode-eslint"
        "ms-vscode.vscode-json"
        "formulahendry.auto-rename-tag"
        "christian-kohler.path-intellisense"
        "ms-vscode.vscode-live-server"
        "ritwickdey.liveserver"
        "ms-vscode.vscode-git-graph"
        "eamodio.gitlens"
        "ms-vscode.hexeditor"
        "ms-vscode-remote.remote-containers"
        "ms-vscode-remote.remote-ssh"
    )

    for extension in "${extensions[@]}"; do
        log_info "Installing VS Code extension: $extension"
        code --install-extension "$extension" || log_warn "Failed to install $extension"
    done

    # Create VS Code settings for web development
    local vscode_dir="$HOME/Library/Application Support/Code/User"
    if [[ ! -d "$vscode_dir" ]]; then
        vscode_dir="$HOME/.config/Code/User"
    fi

    ensure_dir "$vscode_dir"

    cat > "$vscode_dir/settings.json" << 'EOF'
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true,
    "source.organizeImports": true
  },
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  "emmet.includeLanguages": {
    "javascript": "javascriptreact",
    "typescript": "typescriptreact"
  },
  "typescript.preferences.importModuleSpecifier": "relative",
  "javascript.suggest.autoImports": true,
  "typescript.suggest.autoImports": true,
  "npm.enableRunFromFolder": true,
  "terminal.integrated.cwd": "${workspaceFolder}",
  "search.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/build": true,
    "**/.next": true,
    "**/.nuxt": true
  },
  "files.exclude": {
    "**/.git": true,
    "**/.DS_Store": true,
    "**/Thumbs.db": true,
    "**/node_modules": true,
    "**/dist": true,
    "**/build": true
  }
}
EOF

    log_info "VS Code extensions and settings setup completed"
}

setup_database_tools() {
    log_info "Setting up database development tools..."

    local platform=$(detect_platform)

    case "$platform" in
        "macos")
            # Install database tools with Homebrew
            local db_tools=("postgresql" "redis" "mongodb/brew/mongodb-community")
            for tool in "${db_tools[@]}"; do
                if command_exists brew && ! brew list "$tool" >/dev/null 2>&1; then
                    log_info "Installing $tool..."
                    brew install "$tool"
                fi
            done
            ;;
        "linux")
            # Install database tools with system package manager
            case $(detect_package_manager) in
                "apt")
                    sudo apt-get update
                    sudo apt-get install -y postgresql-client redis-tools mongodb-clients
                    ;;
                "yum"|"dnf")
                    sudo "$package_manager" install -y postgresql redis mongodb
                    ;;
                "pacman")
                    sudo pacman -S --noconfirm postgresql redis mongodb
                    ;;
            esac
            ;;
    esac

    # Create database connection aliases
    cat >> "$HOME/.zshrc" << 'EOF'

# Database aliases for web development
alias pg-start="brew services start postgresql || sudo systemctl start postgresql"
alias pg-stop="brew services stop postgresql || sudo systemctl stop postgresql"
alias redis-start="brew services start redis || sudo systemctl start redis"
alias redis-stop="brew services stop redis || sudo systemctl stop redis"
alias mongo-start="brew services start mongodb-community || sudo systemctl start mongod"
alias mongo-stop="brew services stop mongodb-community || sudo systemctl stop mongod"
EOF

    log_info "Database tools setup completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi