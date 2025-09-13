#!/bin/bash

#==============================================================================
# Zsh 配置迁移脚本 - Zsh Configuration Migration Script
#==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Zsh Configuration Migration Script"
echo "Script directory: $SCRIPT_DIR"
echo ""

# Check if we're in the right directory
if [[ ! -f "$SCRIPT_DIR/zshrc.symlink" ]]; then
    echo "Error: Cannot find zshrc.symlink in current directory"
    echo "Please run this script from the shells/zsh directory"
    exit 1
fi

# Backup existing configurations
echo "Creating backups of existing configurations..."
BACKUP_DIR="$SCRIPT_DIR/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

cp -v "$SCRIPT_DIR/zshrc.symlink" "$BACKUP_DIR/" 2>/dev/null || true
cp -v "$SCRIPT_DIR/zprofile.symlink" "$BACKUP_DIR/" 2>/dev/null || true
cp -v "$SCRIPT_DIR/zshenv.symlink" "$BACKUP_DIR/" 2>/dev/null || true
cp -v "$SCRIPT_DIR/aliases.zsh" "$BACKUP_DIR/" 2>/dev/null || true

echo "Backups created in: $BACKUP_DIR"
echo ""

# Function to replace symlinks with new content
replace_file() {
    local old_file="$1"
    local new_file="$2"

    if [[ -f "$old_file" && -f "$new_file" ]]; then
        echo "Replacing $old_file with $new_file"
        mv "$old_file" "${old_file}.backup"
        mv "$new_file" "$old_file"
        echo "✓ Replaced $old_file"
    else
        echo "✗ Skipping $old_file (file not found)"
    fi
}

# Replace the old files with new ones
echo "Replacing old configuration files with new structured ones..."

replace_file "$SCRIPT_DIR/zshrc.symlink" "$SCRIPT_DIR/zshrc.new"
replace_file "$SCRIPT_DIR/zprofile.symlink" "$SCRIPT_DIR/zprofile.new"
replace_file "$SCRIPT_DIR/zshenv.symlink" "$SCRIPT_DIR/zshenv.new"

echo ""
echo "Migration completed!"
echo ""
echo "New structure created:"
echo "  - common/     : Shared configurations across all platforms"
echo "  - mac/        : MacOS-specific configurations"
echo "  - linux/      : Linux-specific configurations"
echo ""
echo "Files:"
echo "  - common/base.zsh     : Base Zsh configuration and plugin setup"
echo "  - common/paths.zsh    : Common PATH and environment setup"
echo "  - common/functions.zsh: Utility functions"
echo "  - common/aliases.zsh  : Common aliases"
echo "  - common/fzf.zsh      : FZF configuration"
echo "  - common/lazyload.zsh : Lazy loading for tools"
echo "  - common/final.zsh    : Final configuration loading"
echo "  - mac/env.zsh         : MacOS environment variables"
echo "  - mac/path.zsh        : MacOS-specific paths"
echo "  - mac/tools.zsh       : MacOS-specific tools"
echo "  - linux/env.zsh       : Linux environment variables"
echo "  - linux/path.zsh      : Linux-specific paths"
echo "  - linux/tools.zsh     : Linux-specific tools"
echo ""
echo "To test the new configuration:"
echo "  1. Open a new terminal"
echo "  2. If you encounter any issues, restore from backups: $BACKUP_DIR"
echo "  3. Report any problems to help improve the configuration"
echo ""
echo "Would you like to see the differences between old and new files? (y/N)"
read -r show_diff
if [[ "$show_diff" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Differences:"
    echo "============"
    for file in zshrc.symlink zprofile.symlink zshenv.symlink; do
        if [[ -f "$SCRIPT_DIR/${file}.backup" ]]; then
            echo ""
            echo "--- $file ---"
            diff -u "$SCRIPT_DIR/${file}.backup" "$SCRIPT_DIR/$file" | head -50
        fi
    done
fi

echo ""
echo "Migration script completed successfully! 🎉"