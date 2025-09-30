#!/bin/bash

# Configuration Backup Script
# Creates comprehensive backups of dotfiles and system configurations

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/utils.sh"

# Configuration
readonly BACKUP_ROOT="$HOME/.dotfiles-backups"
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly BACKUP_DIR="$BACKUP_ROOT/backup_$TIMESTAMP"
readonly METADATA_FILE="$BACKUP_DIR/backup_metadata.json"

# Backup options
INCLUDE_SYSTEM_CONFIGS=false
INCLUDE_APPLICATION_DATA=false
COMPRESS_BACKUP=false
ENCRYPT_BACKUP=false
AUTO_CONFIRM=false

# File patterns to include/exclude
declare -a INCLUDE_PATTERNS=(
    ".zshrc"
    ".zshenv"
    ".zprofile"
    ".gitconfig"
    ".tmux.conf"
    ".vimrc"
    ".vim"
    ".config/alacritty"
    ".config/hyper"
    ".config/nvim"
    ".config/fish"
    ".ssh/config"
    ".ssh/known_hosts"
    ".fzf.zsh"
    ".p10k.zsh"
)

declare -a EXCLUDE_PATTERNS=(
    ".cache"
    ".local/share"
    ".local/state"
    ".npm"
    ".node_modules"
    ".git"
    ".DS_Store"
    "*.tmp"
    "*.log"
    "*.swp"
    "*.swo"
    ".vim/tmp"
    ".vim/undo"
    ".vim/plugged"
    ".tmux/resurrect"
    "*.backup.*"
)

# Help function
show_help() {
    cat << EOF
Configuration Backup Script

Usage: $(basename "$0") [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output
    -y, --yes               Auto-confirm all prompts
    --include-system        Include system-wide configurations
    --include-apps          Include application data
    --compress              Compress backup with tar.gz
    --encrypt               Encrypt backup (requires gpg)
    --output DIR            Specify output directory
    --patterns FILE         Read include patterns from file

EXAMPLES:
    backup.sh --compress --encrypt
    backup.sh --include-system --output /path/to/backups
    backup.sh --yes --include-apps

DESCRIPTION:
    This script creates comprehensive backups of your dotfiles and
    configuration files. It includes metadata about the backup
    and supports compression and encryption options.
EOF
}

# Backup metadata management
create_backup_metadata() {
    local backup_type="$1"
    local file_count="$2"
    local total_size="$3"

    cat > "$METADATA_FILE" << EOF
{
    "backup_info": {
        "timestamp": "$TIMESTAMP",
        "backup_type": "$backup_type",
        "platform": "$(detect_platform)",
        "hostname": "$(hostname)",
        "user": "$USER",
        "shell": "$(detect_shell)",
        "dotfiles_commit": "$(git -C "$(get_dotfiles_root)" rev-parse HEAD 2>/dev/null || echo "unknown")"
    },
    "backup_statistics": {
        "files_count": $file_count,
        "total_size_bytes": $total_size,
        "total_size_human": "$(numfmt --to=iec $total_size)",
        "compression_enabled": $COMPRESS_BACKUP,
        "encryption_enabled": $ENCRYPT_BACKUP
    },
    "backup_contents": {
        "include_patterns": [$(printf '"%s",' "${INCLUDE_PATTERNS[@]}" | sed 's/,$//')],
        "exclude_patterns": [$(printf '"%s",' "${EXCLUDE_PATTERNS[@]}" | sed 's/,$//')],
        "system_configs": $INCLUDE_SYSTEM_CONFIGS,
        "application_data": $INCLUDE_APPLICATION_DATA
    },
    "backup_tools": {
        "script_version": "1.0",
        "created_by": "$(basename "$0")",
        "git_version": "$(git --version 2>/dev/null || echo 'unknown')",
        "tar_version": "$(tar --version | head -1 2>/dev/null || echo 'unknown')"
    }
}
EOF

    log_info "Created backup metadata: $METADATA_FILE"
}

# File discovery and filtering
discover_files() {
    local search_root="${1:-$HOME}"
    local files_found=0

    log_info "Discovering configuration files..."

    # Create temporary file list
    local temp_filelist=$(mktemp)

    # Find files matching include patterns
    for pattern in "${INCLUDE_PATTERNS[@]}"; do
        while IFS= read -r -d '' file; do
            echo "$file" >> "$temp_filelist"
            ((files_found++))
        done < <(find "$search_root" -path "*/$pattern*" -type f -print0 2>/dev/null)
    done

    # Apply exclude patterns
    local filtered_filelist=$(mktemp)
    while IFS= read -r file; do
        local should_include=true
        for pattern in "${EXCLUDE_PATTERNS[@]}"; do
            if [[ "$file" == *"$pattern"* ]]; then
                should_include=false
                break
            fi
        done
        if [[ "$should_include" == "true" ]]; then
            echo "$file" >> "$filtered_filelist"
        fi
    done < "$temp_filelist"

    # Cleanup and return filtered list
    rm "$temp_filelist"
    echo "$filtered_filelist"
}

# System configuration backup
backup_system_configs() {
    if [[ "$INCLUDE_SYSTEM_CONFIGS" != "true" ]]; then
        return 0
    fi

    section "Backing Up System Configurations"

    local system_backup_dir="$BACKUP_DIR/system"
    ensure_dir "$system_backup_dir"

    # Platform-specific system configs
    case $(detect_platform) in
        "macos")
            backup_macos_configs "$system_backup_dir"
            ;;
        "linux")
            backup_linux_configs "$system_backup_dir"
            ;;
    esac

    # Common system configs
    local common_configs=(
        "/etc/hosts"
        "/etc/environment"
        "/etc/profile"
    )

    for config in "${common_configs[@]}"; do
        if [[ -f "$config" ]] && [[ -r "$config" ]]; then
            cp "$config" "$system_backup_dir/" 2>/dev/null || true
        fi
    done
}

backup_macos_configs() {
    local backup_dir="$1/macos"

    ensure_dir "$backup_dir"

    # Backup macOS preferences
    local macos_defaults=(
        "com.apple.Terminal"
        "com.apple finder"
        "com.apple.dock"
        "com.apple.Safari"
        "com.googlecode.iterm2"
    )

    for domain in "${macos_defaults[@]}"; do
        if defaults read "$domain" >/dev/null 2>&1; then
            defaults read "$domain" > "$backup_dir/$domain.plist" 2>/dev/null || true
        fi
    done

    # Backup Homebrew
    if command_exists brew; then
        brew list > "$backup_dir/brew_packages.txt"
        brew list --cask > "$backup_dir/brew_casks.txt"
        brew leaves > "$backup_dir/brew_leaves.txt"
    fi
}

backup_linux_configs() {
    local backup_dir="$1/linux"

    ensure_dir "$backup_dir"

    # Backup package lists
    case $(detect_package_manager) in
        "apt")
            dpkg --get-selections > "$backup_dir/apt_packages.txt"
            apt list --installed > "$backup_dir/apt_installed.txt" 2>/dev/null || true
            ;;
        "yum"|"dnf")
            "$package_manager" list installed > "$backup_dir/${package_manager}_packages.txt"
            ;;
        "pacman")
            pacman -Qqe > "$backup_dir/pacman_packages.txt"
            ;;
    esac

    # Backup system information
    uname -a > "$backup_dir/uname.txt"
    lsb_release -a > "$backup_dir/lsb_release.txt" 2>/dev/null || true
    cat /etc/os-release > "$backup_dir/os_release.txt" 2>/dev/null || true
}

# Application data backup
backup_application_data() {
    if [[ "$INCLUDE_APPLICATION_DATA" != "true" ]]; then
        return 0
    fi

    section "Backing Up Application Data"

    local app_backup_dir="$BACKUP_DIR/applications"
    ensure_dir "$app_backup_dir"

    # Backup shell histories
    if [[ -f "$HOME/.zsh_history" ]]; then
        cp "$HOME/.zsh_history" "$app_backup_dir/zsh_history"
    fi

    if [[ -f "$HOME/.bash_history" ]]; then
        cp "$HOME/.bash_history" "$app_backup_dir/bash_history"
    fi

    # Backup development tool configs
    local dev_configs=(
        "$HOME/.npmrc"
        "$HOME/.yarnrc"
        "$HOME/.pnpmrc"
        "$HOME/.pip/pip.conf"
        "$HOME/.condarc"
        "$HOME/.cargo/config"
        "$HOME/.gemrc"
    )

    for config in "${dev_configs[@]}"; do
        if [[ -f "$config" ]]; then
            local config_name=$(basename "$config")
            cp "$config" "$app_backup_dir/$config_name"
        fi
    done
}

# Backup compression
compress_backup() {
    if [[ "$COMPRESS_BACKUP" != "true" ]]; then
        return 0
    fi

    section "Compressing Backup"

    local compressed_file="$BACKUP_DIR.tar.gz"

    log_info "Compressing backup to $compressed_file..."

    tar -czf "$compressed_file" -C "$(dirname "$BACKUP_DIR")" "$(basename "$BACKUP_DIR")"

    if [[ $? -eq 0 ]]; then
        local original_size=$(du -sb "$BACKUP_DIR" | cut -f1)
        local compressed_size=$(du -sb "$compressed_file" | cut -f1)
        local compression_ratio=$(( (original_size - compressed_size) * 100 / original_size ))

        status_ok "Backup compressed successfully"
        log_info "Compression ratio: ${compression_ratio}%"
        log_info "Original size: $(numfmt --to=iec $original_size)"
        log_info "Compressed size: $(numfmt --to=iec $compressed_size)"

        # Remove uncompressed backup after successful compression
        rm -rf "$BACKUP_DIR"
        BACKUP_DIR="$compressed_file"
    else
        status_error "Backup compression failed"
        return 1
    fi
}

# Backup encryption
encrypt_backup() {
    if [[ "$ENCRYPT_BACKUP" != "true" ]]; then
        return 0
    fi

    section "Encrypting Backup"

    if ! command_exists gpg; then
        log_error "GPG not found. Cannot encrypt backup."
        return 1
    fi

    local encrypted_file="$BACKUP_DIR.gpg"

    log_info "Encrypting backup to $encrypted_file..."

    # Get recipient (use first available GPG key or ask user)
    local recipient=""
    if [[ -n "${GPG_RECIPIENT:-}" ]]; then
        recipient="$GPG_RECIPIENT"
    else
        # List available GPG keys
        local keys=$(gpg --list-public-keys --with-colons 2>/dev/null | grep '^uid' | cut -d: -f10 | head -5)
        if [[ -n "$keys" ]]; then
            log_info "Available GPG keys:"
            echo "$keys" | nl
            read -p "Enter key number or email: " choice
            recipient=$(echo "$keys" | sed -n "${choice}p")
        else
            read -p "Enter GPG recipient email: " recipient
        fi
    fi

    if [[ -n "$recipient" ]]; then
        gpg --trust-model always --encrypt -r "$recipient" --output "$encrypted_file" "$BACKUP_DIR"

        if [[ $? -eq 0 ]]; then
            status_ok "Backup encrypted successfully"
            # Remove unencrypted backup
            rm -rf "$BACKUP_DIR"
            BACKUP_DIR="$encrypted_file"
        else
            status_error "Backup encryption failed"
            return 1
        fi
    else
        log_error "No GPG recipient specified"
        return 1
    fi
}

# Backup verification
verify_backup() {
    section "Verifying Backup"

    if [[ -f "$BACKUP_DIR" ]]; then
        # Single file backup (compressed or encrypted)
        local file_size=$(stat -f%z "$BACKUP_DIR" 2>/dev/null || stat -c%s "$BACKUP_DIR" 2>/dev/null)
        if [[ $file_size -gt 0 ]]; then
            status_ok "Backup file verified (size: $(numfmt --to=iec $file_size))"
        else
            status_error "Backup file is empty"
            return 1
        fi
    elif [[ -d "$BACKUP_DIR" ]]; then
        # Directory backup
        local file_count=$(find "$BACKUP_DIR" -type f | wc -l)
        local total_size=$(du -sb "$BACKUP_DIR" | cut -f1)

        if [[ $file_count -gt 0 ]]; then
            status_ok "Backup directory verified ($file_count files, $(numfmt --to=iec $total_size))"
        else
            status_error "Backup directory is empty"
            return 1
        fi
    else
        status_error "Backup not found"
        return 1
    fi
}

# Cleanup old backups
cleanup_old_backups() {
    local max_backups=${1:-10}

    local backup_count=$(ls -1d "$BACKUP_ROOT"/backup_* 2>/dev/null | wc -l)
    if [[ $backup_count -gt $max_backups ]]; then
        local backups_to_remove=$((backup_count - max_backups))
        log_info "Removing $backups_to_remove old backups..."

        ls -1t "$BACKUP_ROOT"/backup_* | tail -n "$backups_to_remove" | while read -r backup; do
            log_info "Removing old backup: $(basename "$backup")"
            rm -rf "$backup"
        done
    fi
}

# Main backup function
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                export LOG_LEVEL=$DEBUG
                shift
                ;;
            -y|--yes)
                AUTO_CONFIRM=true
                shift
                ;;
            --include-system)
                INCLUDE_SYSTEM_CONFIGS=true
                shift
                ;;
            --include-apps)
                INCLUDE_APPLICATION_DATA=true
                shift
                ;;
            --compress)
                COMPRESS_BACKUP=true
                shift
                ;;
            --encrypt)
                ENCRYPT_BACKUP=true
                shift
                ;;
            --output)
                BACKUP_ROOT="$2"
                shift 2
                ;;
            --patterns)
                if [[ -f "$2" ]]; then
                    readarray -t INCLUDE_PATTERNS < "$2"
                fi
                shift 2
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Start backup process
    section "Configuration Backup"
    log_info "Starting backup process..."
    log_info "Backup directory: $BACKUP_DIR"

    # Ensure backup directory exists
    ensure_dir "$BACKUP_ROOT"

    # Confirmation prompt
    if [[ "$AUTO_CONFIRM" != "true" ]]; then
        echo -e "\n${WHITE}Backup Configuration:${NC}"
        echo "  Include system configs: $INCLUDE_SYSTEM_CONFIGS"
        echo "  Include application data: $INCLUDE_APPLICATION_DATA"
        echo "  Compress backup: $COMPRESS_BACKUP"
        echo "  Encrypt backup: $ENCRYPT_BACKUP"
        echo

        if ! ask_yes_no "Proceed with backup?"; then
            log_info "Backup cancelled"
            exit 0
        fi
    fi

    # Create backup directory
    ensure_dir "$BACKUP_DIR"

    # Discover and backup files
    local filelist=$(discover_files)
    local file_count=0
    local total_size=0

    log_info "Copying configuration files..."
    while IFS= read -r file; do
        if [[ -n "$file" && -f "$file" ]]; then
            local relative_path="${file#$HOME/}"
            local backup_file="$BACKUP_DIR/configs/$relative_path"
            ensure_dir "$(dirname "$backup_file")"
            cp "$file" "$backup_file"

            local file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
            ((total_size += file_size))
            ((file_count++))

            if [[ $(echo "$file_count % 50 == 0" | bc) -eq 1 ]]; then
                log_info "Backed up $file_count files..."
            fi
        fi
    done < "$filelist"

    rm "$filelist"

    # Backup additional data
    backup_system_configs
    backup_application_data

    # Create metadata
    create_backup_metadata "full" "$file_count" "$total_size"

    # Apply post-processing
    compress_backup
    encrypt_backup

    # Verify backup
    verify_backup

    # Cleanup old backups
    cleanup_old_backups

    # Summary
    echo -e "\n${GREEN}=== Backup Complete ===${NC}"
    log_info "Files backed up: $file_count"
    log_info "Total size: $(numfmt --to=iec $total_size)"
    log_info "Backup location: $BACKUP_DIR"
    log_info "Metadata: $METADATA_FILE"

    if [[ "$COMPRESS_BACKUP" == "true" ]]; then
        log_info "Backup is compressed"
    fi

    if [[ "$ENCRYPT_BACKUP" == "true" ]]; then
        log_info "Backup is encrypted"
    fi

    log_success "Backup completed successfully!"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi