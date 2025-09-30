#!/bin/bash

# Unified Dotfiles Configuration Manager
# Central interface for managing all dotfiles operations

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"

# Configuration
readonly DOTFILES_ROOT=$(get_dotfiles_root)
readonly BACKUP_DIR="$HOME/.dotfiles-backups"
readonly LOCK_FILE="$HOME/.dotfiles-manager.lock"

# Manager functions
show_help() {
    cat << 'EOF'
Dotfiles Configuration Manager

Usage: dotfile-manager <command> [options]

Commands:
    install     Install dotfiles to system
    update      Update existing configurations
    sync        Sync configurations across systems
    backup      Backup current configurations
    restore     Restore from backup
    status      Show system status
    doctor      Run diagnostics
    health      Run health check
    validate    Validate configuration files
    clean       Clean up old backups

Options:
    -h, --help          Show this help
    -v, --verbose       Verbose output
    -y, --yes           Skip confirmation prompts
    -f, --force         Force operation
    --dry-run           Show what would be done without executing

Examples:
    dotfile-manager install --verbose
    dotfile-manager update --force
    dotfile-manager backup --yes
    dotfile-manager status
    dotfile-manager doctor
    dotfile-manager health

For more information, see the documentation at:
https://github.com/yourusername/dotfiles
EOF
}

install_dotfiles() {
    local force=${1:-false}
    local dry_run=${2:-false}

    section "Installing Dotfiles"
    log_info "Installing dotfiles from $DOTFILES_ROOT"

    # Ensure backup directory exists
    if [[ "$dry_run" != "true" ]]; then
        ensure_dir "$BACKUP_DIR"
    fi

    # Find and process all symlink files
    local total_files=0
    local processed_files=0

    while IFS= read -r -d '' symlink_file; do
        ((total_files++))
        local basename_file=$(basename "$symlink_file")
        local target_name

        # Determine target file name based on symlink suffix
        case "$basename_file" in
            *.macsymlink)
                if [[ $(detect_platform) != "macos" ]]; then
                    log_debug "Skipping macOS-specific file: $basename_file"
                    continue
                fi
                target_name="${basename_file%.macsymlink}"
                ;;
            *.linuxsymlink)
                if [[ $(detect_platform) != "linux" ]]; then
                    log_debug "Skipping Linux-specific file: $basename_file"
                    continue
                fi
                target_name="${basename_file%.linuxsymlink}"
                ;;
            *.winsymlink)
                if [[ $(detect_platform) != "windows" ]]; then
                    log_debug "Skipping Windows-specific file: $basename_file"
                    continue
                fi
                target_name="${basename_file%.winsymlink}"
                ;;
            *.symlink)
                target_name="${basename_file%.symlink}"
                ;;
            *)
                log_debug "Skipping non-symlink file: $basename_file"
                continue
                ;;
        esac

        local target_path="$HOME/$target_name"
        local source_path="$symlink_file"

        log_info "Processing: $target_name"

        if [[ "$dry_run" == "true" ]]; then
            echo "Would create symlink: $target_path -> $source_path"
        else
            if safe_symlink "$source_path" "$target_path" "$BACKUP_DIR"; then
                status_ok "Installed: $target_name"
                ((processed_files++))
            else
                status_error "Failed to install: $target_name"
            fi
        fi
    done < <(find "$DOTFILES_ROOT" -name "*.symlink" -o -name "*.macsymlink" -o -name "*.linuxsymlink" -o -name "*.winsymlink" -print0)

    if [[ "$dry_run" != "true" ]]; then
        log_success "Processed $processed_files/$total_files files"
    else
        echo "Would process $total_files files"
    fi
}

update_dotfiles() {
    local force=${1:-false}
    local dry_run=${2:-false}

    section "Updating Dotfiles"

    # Update git repository
    if is_git_repo "$DOTFILES_ROOT"; then
        if [[ "$dry_run" != "true" ]]; then
            log_info "Updating dotfiles repository..."
            cd "$DOTFILES_ROOT"

            if [[ "$force" == "true" ]]; then
                git fetch --all
                git reset --hard origin/HEAD
            else
                git pull origin HEAD
            fi

            log_success "Repository updated"
        else
            echo "Would update git repository"
        fi
    else
        status_warn "Not a git repository, skipping update"
    fi

    # Reinstall symlinks
    install_dotfiles "$force" "$dry_run"

    # Update submodules if any
    if [[ -f "$DOTFILES_ROOT/.gitmodules" ]] && [[ "$dry_run" != "true" ]]; then
        log_info "Updating submodules..."
        cd "$DOTFILES_ROOT"
        git submodule update --init --recursive
        log_success "Submodules updated"
    fi
}

backup_configurations() {
    local auto_confirm=${1:-false}

    section "Backing Up Configurations"

    local backup_timestamp=$(date +%Y%m%d_%H%M%S)
    local current_backup_dir="$BACKUP_DIR/backup_$backup_timestamp"

    if [[ "$auto_confirm" != "true" ]]; then
        if ! ask_yes_no "Create backup in $current_backup_dir?"; then
            log_info "Backup cancelled"
            return 0
        fi
    fi

    ensure_dir "$current_backup_dir"

    local backed_up_files=0

    # Backup dotfile-managed configurations
    while IFS= read -r -d '' file; do
        if is_dotfile_managed "$file"; then
            local relative_path="${file#$HOME/}"
            local backup_file="$current_backup_dir/$relative_path"
            ensure_dir "$(dirname "$backup_file")"
            cp "$file" "$backup_file"
            ((backed_up_files++))
            log_debug "Backed up: $relative_path"
        fi
    done < <(find "$HOME" -maxdepth 3 -type f -print0 2>/dev/null)

    # Backup critical configuration files
    local critical_configs=(".zshrc" ".zshenv" ".gitconfig" ".tmux.conf" ".vimrc")
    for config in "${critical_configs[@]}"; do
        if [[ -f "$HOME/$config" ]]; then
            cp "$HOME/$config" "$current_backup_dir/"
            ((backed_up_files++))
        fi
    done

    # Create backup metadata
    cat > "$current_backup_dir/backup_info.txt" << EOF
Backup created: $(date)
Platform: $(detect_platform)
Files backed up: $backed_up_files
Dotfiles commit: $(git -C "$DOTFILES_ROOT" rev-parse HEAD 2>/dev/null || echo "unknown")
EOF

    log_success "Backup created: $current_backup_dir ($backed_up_files files)"
}

restore_configurations() {
    local backup_dir="$1"

    if [[ -z "$backup_dir" ]]; then
        # List available backups
        section "Available Backups"
        local backups=($(ls -1t "$BACKUP_DIR" 2>/dev/null | grep '^backup_' || true))

        if [[ ${#backups[@]} -eq 0 ]]; then
            log_error "No backups found"
            return 1
        fi

        echo "Select backup to restore:"
        for i in "${!backups[@]}"; do
            local backup_path="$BACKUP_DIR/${backups[i]}"
            local backup_info="$backup_path/backup_info.txt"
            if [[ -f "$backup_info" ]]; then
                local backup_date=$(grep "Backup created:" "$backup_info" | cut -d: -f2- | xargs)
                echo "$((i+1))) ${backups[i]} (created: $backup_date)"
            else
                echo "$((i+1))) ${backups[i]}"
            fi
        done

        local choice=$(ask_choice "Enter choice:" "${backups[@]}")
        backup_dir="$BACKUP_DIR/$choice"
    fi

    if [[ ! -d "$backup_dir" ]]; then
        log_error "Backup directory not found: $backup_dir"
        return 1
    fi

    section "Restoring from Backup"
    log_info "Restoring from: $backup_dir"

    if ask_yes_no "This will overwrite current configurations. Continue?"; then
        local restored_files=0

        while IFS= read -r -d '' file; do
            local relative_path="${file#$backup_dir/}"
            local target_path="$HOME/$relative_path"

            ensure_dir "$(dirname "$target_path")"
            cp "$file" "$target_path"
            ((restored_files++))
            log_info "Restored: $relative_path"
        done < <(find "$backup_dir" -type f ! -name "backup_info.txt" -print0)

        log_success "Restored $restored_files files from backup"
    else
        log_info "Restore cancelled"
    fi
}

show_status() {
    section "Dotfiles Status"

    # Repository status
    if is_git_repo "$DOTFILES_ROOT"; then
        status_ok "Dotfiles is a git repository"
        local git_status=$(git_repo_status "$DOTFILES_ROOT")
        echo "  $git_status"
    else
        status_warn "Dotfiles is not a git repository"
    fi

    # Symlink status
    local total_symlinks=0
    local managed_symlinks=0
    local broken_symlinks=0

    while IFS= read -r -d '' file; do
        if [[ -L "$file" ]]; then
            ((total_symlinks++))
            if is_dotfile_managed "$file"; then
                ((managed_symlinks++))
            fi
        fi
    done < <(find "$HOME" -maxdepth 3 -type l -print0 2>/dev/null)

    while IFS= read -r symlink; do
        if [[ -n "$symlink" ]]; then
            ((broken_symlinks++))
        fi
    done < <(find_broken_symlinks "$HOME" | head -20)

    echo -e "\n${WHITE}Symlink Status:${NC}"
    echo "  Total symlinks: $total_symlinks"
    echo "  Managed by dotfiles: $managed_symlinks"
    echo "  Broken symlinks: $broken_symlinks"

    # Backup status
    echo -e "\n${WHITE}Backup Status:${NC}"
    local backup_count=$(ls -1 "$BACKUP_DIR" 2>/dev/null | grep '^backup_' | wc -l || echo "0")
    echo "  Available backups: $backup_count"
    if [[ $backup_count -gt 0 ]]; then
        local latest_backup=$(ls -1t "$BACKUP_DIR"/backup_* 2>/dev/null | head -1)
        echo "  Latest backup: $(basename "$latest_backup")"
    fi

    # Platform info
    echo -e "\n${WHITE}Platform Information:${NC}"
    get_system_info
}

run_doctor() {
    section "Dotfiles Doctor"
    log_info "Running comprehensive diagnostics..."

    local issues_found=0

    # Check repository integrity
    if ! is_git_repo "$DOTFILES_ROOT"; then
        status_error "Not a git repository"
        ((issues_found++))
    fi

    # Check for broken symlinks
    local broken_count=$(find_broken_symlinks "$HOME" | wc -l)
    if [[ $broken_count -gt 0 ]]; then
        status_error "Found $broken_count broken symlinks"
        ((issues_found++))
    fi

    # Check for uncommitted changes
    if is_git_repo "$DOTFILES_ROOT"; then
        cd "$DOTFILES_ROOT"
        local uncommitted=$(git status --porcelain 2>/dev/null | wc -l)
        if [[ $uncommitted -gt 0 ]]; then
            status_warn "$uncommitted uncommitted changes"
            ((issues_found++))
        fi
    fi

    # Check configuration file validity
    if [[ -x "$SCRIPT_DIR/health/validate-config.sh" ]]; then
        if ! "$SCRIPT_DIR/health/validate-config.sh" >/dev/null 2>&1; then
            status_warn "Some configuration files have issues"
            ((issues_found++))
        fi
    fi

    # Summary
    if [[ $issues_found -eq 0 ]]; then
        log_success "No issues found! Everything looks good."
    else
        log_warn "Found $issues_found issues that need attention."
        log_info "Run 'dotfile-manager health' for detailed analysis."
    fi
}

clean_backups() {
    section "Cleaning Old Backups"

    local backup_count=$(ls -1 "$BACKUP_DIR" 2>/dev/null | grep '^backup_' | wc -l || echo "0")

    if [[ $backup_count -eq 0 ]]; then
        log_info "No backups to clean"
        return 0
    fi

    echo "Current backups: $backup_count"
    ls -la "$BACKUP_DIR"/backup_* 2>/dev/null | head -10

    if ask_yes_no "Keep only the 5 most recent backups?"; then
        local backups_to_remove=$(ls -1t "$BACKUP_DIR"/backup_* 2>/dev/null | tail -n +6)
        local removed_count=0

        while IFS= read -r backup; do
            if [[ -n "$backup" && -d "$backup" ]]; then
                rm -rf "$backup"
                ((removed_count++))
                log_info "Removed: $(basename "$backup")"
            fi
        done <<< "$backups_to_remove"

        log_success "Removed $removed_count old backups"
    else
        log_info "Cleanup cancelled"
    fi
}

# Lock file management
acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local lock_age=$(($(date +%s) - $(stat -f %m "$LOCK_FILE" 2>/dev/null || stat -c %Y "$LOCK_FILE" 2>/dev/null)))
        if [[ $lock_age -lt 300 ]]; then  # 5 minutes
            log_error "Another dotfile-manager instance is running"
            exit 1
        else
            log_warn "Removing stale lock file"
            rm -f "$LOCK_FILE"
        fi
    fi
    echo $$ > "$LOCK_FILE"
}

release_lock() {
    rm -f "$LOCK_FILE"
}

# Cleanup on exit
cleanup() {
    release_lock
}
trap cleanup EXIT

# Main execution
main() {
    # Parse command line arguments
    local command=""
    local verbose=false
    local auto_confirm=false
    local force=false
    local dry_run=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                export LOG_LEVEL=$DEBUG
                verbose=true
                shift
                ;;
            -y|--yes)
                auto_confirm=true
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            install|update|sync|backup|restore|status|doctor|health|validate|clean)
                command="$1"
                shift
                ;;
            *)
                log_error "Unknown command: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    # Acquire lock for operations that modify state
    case "$command" in
        install|update|backup|restore|clean)
            acquire_lock
            ;;
    esac

    # Execute command
    case "$command" in
        install)
            install_dotfiles "$force" "$dry_run"
            ;;
        update)
            update_dotfiles "$force" "$dry_run"
            ;;
        sync)
            update_dotfiles "$force" "$dry_run"
            ;;
        backup)
            backup_configurations "$auto_confirm"
            ;;
        restore)
            restore_configurations "${1:-}"
            ;;
        status)
            show_status
            ;;
        doctor)
            run_doctor
            ;;
        health)
            if [[ -x "$SCRIPT_DIR/health/health-check.sh" ]]; then
                "$SCRIPT_DIR/health/health-check.sh"
            else
                log_error "Health check script not found"
                exit 1
            fi
            ;;
        validate)
            if [[ -x "$SCRIPT_DIR/health/validate-config.sh" ]]; then
                "$SCRIPT_DIR/health/validate-config.sh"
            else
                log_error "Validation script not found"
                exit 1
            fi
            ;;
        clean)
            clean_backups
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