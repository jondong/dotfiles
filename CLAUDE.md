# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles management system - a collection of configuration files and scripts for setting up development environments across Linux, macOS, and Windows/Cygwin platforms.

## Key Architecture

### Symlink-Based Configuration System
The repository uses a sophisticated symlink system to deploy configurations:
- `.symlink` - Universal configuration files
- `.macsymlink` - macOS-specific files
- `.linuxsymlink` - Linux-specific files  
- `.winsymlink` - Windows/Cygwin-specific files

Files are deployed using the bootstrap script which creates appropriate symlinks in the user's home directory.

### Platform-Specific Structure
```
platforms/
├── linux/
│   └── install.sh      # Ubuntu/Debian setup using apt
└── mac/
    └── install.sh      # macOS setup using Homebrew
```

### Core Scripts
- `bootstrap.sh` - Main installation script with platform detection
- `platforms/linux/install.sh` - Linux development environment setup
- `platforms/mac/install.sh` - macOS development environment setup

## Common Commands

### Initial Setup
```bash
# Full automated installation
bash <(curl https://raw.githubusercontent.com/jondong/dotfiles/master/bootstrap.sh -L)

# Manual bootstrap with options
./bootstrap.sh --with-vim --with-tmux --auto --parallel
```

### Platform-Specific Installation
```bash
# Linux setup
./platforms/linux/install.sh

# macOS setup
./platforms/mac/install.sh
```

### Testing Configuration Changes
After modifying configuration files, reload the shell:
```bash
source ~/.zshrc  # or simply restart the terminal
```

## Important Patterns

### Platform Detection
The bootstrap script automatically detects the operating system and uses appropriate configurations. The shell configurations contain platform-specific logic for PATH variables and tool availability.

### Performance Optimizations
- Zinit plugin manager with lazy loading for Zsh
- Conditional loading based on available tools
- Caching mechanisms to speed up shell startup
- FZF integration with custom keybindings for fast file searching

### File Linking Strategy
The bootstrap script handles existing files interactively by default, offering options to backup, overwrite, or skip. Use `--auto` flag for unattended installation.

### Configuration Hierarchy
1. Universal configs (`.symlink`)
2. Platform-specific overrides (`.macsymlink`, `.linuxsymlink`, `.winsymlink`)
3. Shell initialization cascades through: zshenv → zprofile → zshrc

## Development Environment Features

### Package Management
- **Linux**: Uses apt for system packages, supports production vs development modes
- **macOS**: Uses Homebrew with categorized package groups (Basic, Utilities, Fonts, DevTools)

### Shell Environment (Zsh)
- Zinit plugin manager with syntax highlighting, auto-suggestions, completions
- FZF integration with custom keybindings (Ctrl-T, Ctrl-R, Alt-C)
- Platform-aware PATH configuration
- Git integration with branch status and prompt customization

### Terminal Applications
- Alacritty terminal emulator with Dracula theme
- Tmux multiplexer with extensive plugin ecosystem
- Vim/Neovim with modern configuration
- Development tool integrations (gdb, aria2)