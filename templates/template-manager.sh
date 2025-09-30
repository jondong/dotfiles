#!/bin/bash

# Development Environment Template Manager
# Manages and applies development environment templates

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common/utils.sh"

# Constants
readonly TEMPLATES_DIR="$SCRIPT_DIR"
readonly CACHE_DIR="$HOME/.dotfiles-cache/templates"
readonly METADATA_FILE="$CACHE_DIR/template_metadata.json"

# Template registry
declare -A TEMPLATES=(
    ["web-development"]="Web Development (React, Vue, Node.js)"
    ["data-science"]="Data Science (Python, R, Jupyter, ML)"
    ["mobile-development"]="Mobile Development (React Native, Flutter)"
    ["backend-development"]="Backend Development (Python, Go, Java, Node.js)"
    ["devops"]="DevOps & Cloud (Docker, K8s, Terraform, AWS)"
    ["gaming"]="Gaming Development (Unity, Godot, Game Engines)"
    ["creative"]="Creative Development (Design, Media, Content)"
    ["full-stack"]="Full Stack Development (Web + Backend + Databases)"
    ["ml-engineering"]="ML Engineering (Data Science + Production + MLOps)"
    ["blockchain"]="Blockchain Development (Web3, Smart Contracts, DeFi)"
)

# Template metadata
declare -A TEMPLATE_DESCRIPTIONS=(
    ["web-development"]="Complete web development environment with modern JavaScript/TypeScript toolchain, frontend frameworks, and backend APIs."
    ["data-science"]="Comprehensive data science environment with Python, R, Jupyter, and machine learning frameworks."
    ["mobile-development"]="Cross-platform mobile development with React Native, Flutter, and native tooling."
    ["backend-development"]="Server-side development with multiple programming languages and database support."
    ["devops"]="Infrastructure as code, containerization, orchestration, and cloud platform tools."
    ["gaming"]="Game development engines, physics, graphics programming, and mobile game development."
    ["creative"]="Design tools, media processing, 3D modeling, and content creation workflows."
    ["full-stack"]="Complete full-stack development with frontend, backend, database, and deployment tools."
    ["ml-engineering"]="End-to-end machine learning engineering from data science to production deployment."
    ["blockchain"]="Blockchain and Web3 development with smart contracts, DApps, and DeFi tools."
)

# Help function
show_help() {
    cat << EOF
Development Environment Template Manager

Usage: $(basename "$0") <command> [options]

COMMANDS:
    list                List available templates
    show <template>     Show template details
    apply <template>     Apply a template to current environment
    create <name>        Create custom template
    status              Show current environment status
    validate <template>  Validate template configuration
    export <template>   Export template configuration
    import <file>       Import template from file

OPTIONS:
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output
    -y, --yes           Skip confirmation prompts
    --dry-run           Show what would be done without executing
    --output DIR        Specify output directory

EXAMPLES:
    template-manager list
    template-manager show web-development
    template-manager apply data-science --yes
    template-manager create my-custom-env
    template-manager status

DESCRIPTION:
    This tool manages development environment templates that include
    package lists, configuration files, environment variables, and
    setup scripts for different development workflows.
EOF
}

# Template validation
validate_template() {
    local template_name="$1"
    local template_dir="$TEMPLATES_DIR/$template_name"

    if [[ ! -d "$template_dir" ]]; then
        log_error "Template not found: $template_name"
        return 1
    fi

    # Check required files
    local required_files=("template.json" "packages.json")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$template_dir/$file" ]]; then
            log_error "Missing required file: $file"
            return 1
        fi
    done

    # Validate JSON syntax
    if command_exists jq; then
        if ! jq . "$template_dir/template.json" >/dev/null 2>&1; then
            log_error "Invalid JSON in template.json"
            return 1
        fi
        if ! jq . "$template_dir/packages.json" >/dev/null 2>&1; then
            log_error "Invalid JSON in packages.json"
            return 1
        fi
    fi

    return 0
}

# List available templates
list_templates() {
    section "Available Development Environment Templates"

    echo -e "${WHITE}Template Name                    Description${NC}"
    echo -e "${WHITE}-------------                    -----------${NC}"

    for template in "${!TEMPLATES[@]}"; do
        printf "  ${BLUE}%-30s${NC} %s\n" "$template" "${TEMPLATES[$template]}"
    done

    echo
    log_info "Use 'template-manager show <template>' for more details"
}

# Show template details
show_template() {
    local template_name="$1"

    if [[ ! -d "$TEMPLATES_DIR/$template_name" ]]; then
        log_error "Template not found: $template_name"
        return 1
    fi

    section "Template: $template_name"
    echo -e "${YELLOW}${TEMPLATE_DESCRIPTIONS[$template_name]}${NC}"
    echo

    # Show template metadata
    if [[ -f "$TEMPLATES_DIR/$template_name/template.json" ]]; then
        subsection "Template Metadata"
        cat "$TEMPLATES_DIR/$template_name/template.json" | jq -r '.' 2>/dev/null || cat "$TEMPLATES_DIR/$template_name/template.json"
        echo
    fi

    # Show packages
    if [[ -f "$TEMPLATES_DIR/$template_name/packages.json" ]]; then
        subsection "Packages and Dependencies"
        cat "$TEMPLATES_DIR/$template_name/packages.json" | jq -r '.' 2>/dev/null || cat "$TEMPLATES_DIR/$template_name/packages.json"
        echo
    fi

    # Show setup scripts
    if [[ -d "$TEMPLATES_DIR/$template_name/scripts" ]]; then
        subsection "Setup Scripts"
        find "$TEMPLATES_DIR/$template_name/scripts" -name "*.sh" -exec basename {} \; | sed 's/^/  • /'
        echo
    fi

    # Show configuration files
    if [[ -d "$TEMPLATES_DIR/$template_name/configs" ]]; then
        subsection "Configuration Files"
        find "$TEMPLATES_DIR/$template_name/configs" -type f -exec basename {} \; | sed 's/^/  • /'
        echo
    fi
}

# Apply template
apply_template() {
    local template_name="$1"
    local dry_run="${2:-false}"
    local auto_confirm="${3:-false}"

    if ! validate_template "$template_name"; then
        return 1
    fi

    local template_dir="$TEMPLATES_DIR/$template_name"
    section "Applying Template: $template_name"

    log_info "Template: ${TEMPLATE_DESCRIPTIONS[$template_name]}"

    if [[ "$auto_confirm" != "true" ]]; then
        if ! ask_yes_no "Apply this template to your development environment?"; then
            log_info "Template application cancelled"
            return 0
        fi
    fi

    # Backup current state
    if [[ "$dry_run" != "true" ]]; then
        log_info "Creating backup before applying template..."
        backup_configurations true
    fi

    # Install packages
    if [[ -f "$template_dir/packages.json" ]]; then
        subsection "Installing Packages"
        install_template_packages "$template_name" "$dry_run"
    fi

    # Apply configurations
    if [[ -d "$template_dir/configs" ]]; then
        subsection "Applying Configurations"
        apply_template_configs "$template_name" "$dry_run"
    fi

    # Run setup scripts
    if [[ -d "$template_dir/scripts" ]]; then
        subsection "Running Setup Scripts"
        run_template_scripts "$template_name" "$dry_run"
    fi

    # Set environment variables
    if [[ -f "$template_dir/env.sh" ]]; then
        subsection "Setting Environment Variables"
        setup_template_environment "$template_name" "$dry_run"
    fi

    # Validate applied template
    if [[ "$dry_run" != "true" ]]; then
        validate_applied_template "$template_name"
    fi

    log_success "Template '$template_name' applied successfully!"
}

# Install template packages
install_template_packages() {
    local template_name="$1"
    local dry_run="$2"
    local packages_file="$TEMPLATES_DIR/$template_name/packages.json"

    if ! command_exists jq; then
        log_warn "jq not found, using basic package installation"
        basic_package_install "$packages_file" "$dry_run"
        return
    fi

    local platform=$(detect_platform)
    local package_manager=$(detect_package_manager)

    # Extract platform-specific packages
    local packages=$(jq -r ".packages.\"$platform\"? // .packages.common? // []" "$packages_file")

    if [[ "$packages" == "[]" ]]; then
        log_info "No packages defined for $platform"
        return
    fi

    log_info "Installing packages for $platform using $package_manager"

    # Convert JSON array to bash array
    local package_list=()
    while IFS= read -r package; do
        if [[ -n "$package" && "$package" != "null" ]]; then
            package_list+=("$package")
        fi
    done < <(echo "$packages" | jq -r '.[]')

    # Install packages
    for package in "${package_list[@]}"; do
        if [[ "$dry_run" == "true" ]]; then
            echo "Would install: $package"
        else
            install_package "$package" "$package_manager"
        fi
    done
}

basic_package_install() {
    local packages_file="$1"
    local dry_run="$2"

    # Basic package installation without jq
    local platform=$(detect_platform)
    log_info "Looking for $platform packages..."

    if grep -q "$platform" "$packages_file"; then
        local packages=$(grep -A 10 "$platform" "$packages_file" | grep '"' | sed 's/[^"]*"\([^"]*\)".*/\1/')
        for package in $packages; do
            if [[ "$dry_run" == "true" ]]; then
                echo "Would install: $package"
            else
                install_package "$package" "$(detect_package_manager)"
            fi
        done
    fi
}

install_package() {
    local package="$1"
    local package_manager="$2"

    case "$package_manager" in
        "homebrew")
            if ! brew list "$package" >/dev/null 2>&1; then
                log_info "Installing $package with Homebrew..."
                brew install "$package"
            else
                log_info "$package already installed"
            fi
            ;;
        "apt")
            if ! dpkg -l "$package" >/dev/null 2>&1; then
                log_info "Installing $package with apt..."
                sudo apt install -y "$package"
            else
                log_info "$package already installed"
            fi
            ;;
        "yum"|"dnf")
            if ! "$package_manager" list installed "$package" >/dev/null 2>&1; then
                log_info "Installing $package with $package_manager..."
                sudo "$package_manager" install -y "$package"
            else
                log_info "$package already installed"
            fi
            ;;
        "pacman")
            if ! pacman -Qi "$package" >/dev/null 2>&1; then
                log_info "Installing $package with pacman..."
                sudo pacman -S --noconfirm "$package"
            else
                log_info "$package already installed"
            fi
            ;;
        *)
            log_warn "Package manager $package_manager not supported for $package"
            ;;
    esac
}

# Apply template configurations
apply_template_configs() {
    local template_name="$1"
    local dry_run="$2"
    local configs_dir="$TEMPLATES_DIR/$template_name/configs"

    find "$configs_dir" -type f | while read -r config_file; do
        local relative_path="${config_file#$configs_dir/}"
        local target_path="$HOME/$relative_path"

        if [[ "$dry_run" == "true" ]]; then
            echo "Would copy config: $relative_path -> $target_path"
        else
            ensure_dir "$(dirname "$target_path")"
            cp "$config_file" "$target_path"
            log_info "Applied configuration: $relative_path"
        fi
    done
}

# Run template setup scripts
run_template_scripts() {
    local template_name="$1"
    local dry_run="$2"
    local scripts_dir="$TEMPLATES_DIR/$template_name/scripts"

    find "$scripts_dir" -name "*.sh" | sort | while read -r script_file; do
        local script_name=$(basename "$script_file" .sh)
        if [[ "$dry_run" == "true" ]]; then
            echo "Would run script: $script_name"
        else
            log_info "Running setup script: $script_name"
            chmod +x "$script_file"
            "$script_file"
        fi
    done
}

# Setup template environment
setup_template_environment() {
    local template_name="$1"
    local dry_run="$2"
    local env_file="$TEMPLATES_DIR/$template_name/env.sh"

    if [[ ! -f "$env_file" ]]; then
        return
    fi

    if [[ "$dry_run" == "true" ]]; then
        echo "Would setup environment variables from $env_file"
        return
    fi

    # Source environment file
    source "$env_file"

    # Add to shell profile if not already present
    local shell_rc="$HOME/.zshrc"
    if [[ ! -f "$shell_rc" ]]; then
        shell_rc="$HOME/.bashrc"
    fi

    if [[ -f "$shell_rc" ]]; then
        if ! grep -q "# Dotfiles template: $template_name" "$shell_rc"; then
            echo "" >> "$shell_rc"
            echo "# Dotfiles template: $template_name" >> "$shell_rc"
            echo "source \"$env_file\"" >> "$shell_rc"
            log_info "Added environment variables to $shell_rc"
        fi
    fi
}

# Validate applied template
validate_applied_template() {
    local template_name="$1"
    local validation_file="$TEMPLATES_DIR/$template_name/validate.sh"

    if [[ -f "$validation_file" ]]; then
        log_info "Running template validation..."
        chmod +x "$validation_file"
        if "$validation_file"; then
            status_ok "Template validation passed"
        else
            status_warn "Template validation found some issues"
        fi
    fi
}

# Create custom template
create_template() {
    local template_name="$1"

    if [[ -z "$template_name" ]]; then
        log_error "Template name is required"
        return 1
    fi

    local template_dir="$TEMPLATES_DIR/$template_name"

    if [[ -d "$template_dir" ]]; then
        log_error "Template already exists: $template_name"
        return 1
    fi

    section "Creating Custom Template: $template_name"

    # Create template directory structure
    ensure_dir "$template_dir"
    ensure_dir "$template_dir/configs"
    ensure_dir "$template_dir/scripts"

    # Create template metadata
    cat > "$template_dir/template.json" << EOF
{
    "name": "$template_name",
    "description": "Custom development environment template",
    "version": "1.0.0",
    "author": "$USER",
    "created": "$(date -Iseconds)",
    "platforms": ["macos", "linux"],
    "tags": ["custom"]
}
EOF

    # Create empty packages configuration
    cat > "$template_dir/packages.json" << EOF
{
    "description": "Packages for $template_name template",
    "packages": {
        "common": [],
        "macos": [],
        "linux": {
            "apt": [],
            "yum": [],
            "dnf": [],
            "pacman": []
        }
    }
}
EOF

    # Create sample configuration
    cat > "$template_dir/configs/template-config.conf" << EOF
# Template configuration file
# This is a sample configuration for $template_name

# Add your custom configurations here
EXAMPLE_SETTING=true
ANOTHER_SETTING="custom_value"
EOF

    # Create sample setup script
    cat > "$template_dir/scripts/01-setup.sh" << EOF
#!/bin/bash
# Setup script for $template_name template

echo "Setting up $template_name environment..."

# Add your setup commands here
EOF

    # Create validation script
    cat > "$template_dir/validate.sh" << EOF
#!/bin/bash
# Validation script for $template_name template

echo "Validating $template_name template installation..."

# Add validation commands here
echo "Template validation complete!"
EOF

    # Create environment variables file
    cat > "$template_dir/env.sh" << EOF
#!/bin/bash
# Environment variables for $template_name template

export TEMPLATE_NAME="$template_name"
export TEMPLATE_ROOT="\$HOME/.dotfiles/templates/$template_name"

# Add your environment variables here
# export CUSTOM_VAR="value"
EOF

    chmod +x "$template_dir/scripts/01-setup.sh"
    chmod +x "$template_dir/validate.sh"

    log_success "Custom template '$template_name' created successfully!"
    log_info "Edit the files in $template_dir to customize your template"
}

# Show current environment status
show_status() {
    section "Current Environment Status"

    # Detect current template
    local current_template=""
    if [[ -f "$HOME/.dotfiles-current-template" ]]; then
        current_template=$(cat "$HOME/.dotfiles-current-template")
    fi

    if [[ -n "$current_template" ]]; then
        status_ok "Current template: $current_template"
        echo "Description: ${TEMPLATE_DESCRIPTIONS[$current_template]}"
    else
        status_warn "No template currently applied"
    fi

    # Show system information
    subsection "System Information"
    get_system_info

    # Show installed tools
    subsection "Development Tools"
    local tools=("git" "node" "python3" "docker" "kubectl" "terraform")
    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            local version=$($tool --version 2>/dev/null | head -1 || echo "installed")
            status_ok "$tool: $version"
        else
            status_warn "$tool: not installed"
        fi
    done
}

# Export template configuration
export_template() {
    local template_name="$1"
    local output_file="${2:-${template_name}-export.tar.gz}"

    if ! validate_template "$template_name"; then
        return 1
    fi

    local template_dir="$TEMPLATES_DIR/$template_name"

    log_info "Exporting template: $template_name to $output_file"

    if tar -czf "$output_file" -C "$TEMPLATES_DIR" "$template_name"; then
        log_success "Template exported successfully"
        log_info "Export file: $output_file"
    else
        log_error "Failed to export template"
        return 1
    fi
}

# Import template from file
import_template() {
    local import_file="$1"

    if [[ ! -f "$import_file" ]]; then
        log_error "Import file not found: $import_file"
        return 1
    fi

    local template_name=$(basename "$import_file" .tar.gz)
    template_name=${template_name%-export}

    if [[ -d "$TEMPLATES_DIR/$template_name" ]]; then
        log_error "Template already exists: $template_name"
        return 1
    fi

    log_info "Importing template from $import_file"

    if tar -xzf "$import_file" -C "$TEMPLATES_DIR"; then
        log_success "Template imported successfully"
        log_info "Template name: $template_name"
    else
        log_error "Failed to import template"
        return 1
    fi
}

# Main execution
main() {
    # Parse command line arguments
    local command=""
    local dry_run=false
    local auto_confirm=false
    local verbose=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                export LOG_LEVEL=$DEBUG
                shift
                ;;
            -y|--yes)
                auto_confirm=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --output)
                export OUTPUT_DIR="$2"
                shift 2
                ;;
            list|show|apply|create|status|validate|export|import)
                command="$1"
                shift
                ;;
            *)
                log_error "Unknown command: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Execute command
    case "$command" in
        list)
            list_templates
            ;;
        show)
            show_template "${1:-}"
            ;;
        apply)
            apply_template "${1:-}" "$dry_run" "$auto_confirm"
            ;;
        create)
            create_template "${1:-}"
            ;;
        status)
            show_status
            ;;
        validate)
            validate_template "${1:-}"
            ;;
        export)
            export_template "${1:-}" "${2:-}"
            ;;
        import)
            import_template "${1:-}"
            ;;
        "")
            log_error "No command specified"
            show_help
            exit 1
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi