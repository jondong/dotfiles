# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles management for Linux and macOS development environments. A single bootstrap script sets up the entire environment.

## Directory Structure

```
dotfiles/
├── apps/                  # Application configs (deployed as symlinks)
│   ├── ghostty/
│   └── tmux/
├── bin/                   # Utility scripts (manual use)
├── platforms/             # Platform-specific package installers
│   ├── linux/
│   │   ├── install.sh     # apt-based package installation
│   │   └── aliases.zsh
│   └── mac/
│       ├── install.sh     # Homebrew-based package installation
│       └── aliases.zsh
├── scripts/
│   └── doctor.sh          # Configuration health check & repair
├── shells/zsh/            # Zsh configuration (split by platform)
│   ├── common/            # Shared config (base, paths, aliases, fzf, etc.)
│   ├── linux/             # Linux-specific env, path, tools
│   ├── mac/               # macOS-specific env, path, tools
│   ├── zshrc.symlink
│   ├── zprofile.symlink
│   ├── zshenv.symlink
│   └── p10k.zsh.symlink
├── bootstrap.sh           # Single entry point
└── README.md
```

## Symlink Naming Convention

- `.symlink` — universal, deployed on all platforms
- `.macsymlink` — macOS only
- `.linuxsymlink` — Linux only

## Common Commands

### Initial Setup
```bash
# Minimal: clone, symlinks, zsh, tmux
bash <(curl https://raw.githubusercontent.com/jondong/dotfiles/master/bootstrap.sh -L)

# Full automated: everything including system packages
./bootstrap.sh --with-packages --auto
```

### Health Check & Repair
```bash
./scripts/doctor.sh           # interactive
./scripts/doctor.sh --auto    # auto-fix
```

### Testing Configuration Changes
```bash
source ~/.zshrc
```

## Key Patterns

### Platform Detection
`bootstrap.sh` detects OS via `uname` and selects appropriate configs. Shell configs use `$PLATFORM` (set in zprofile) to load platform-specific files.

### Zsh Loading Chain
```
zshenv → zprofile → zshrc
  ↓         ↓         ↓
env vars  platform  base/paths/aliases/
                    + platform-specific files
                    + dev-tools (NVM, bun, etc.)
                    + final (prompt, SDKMAN, pyenv)
```

### Performance
- Zinit with `light-mode` and lazy loading for plugins
- NVM, rbenv, jenv, direnv are lazy-loaded
- `TERM_PROGRAM` instead of `ps` for terminal detection

### Mandatory Components
Zsh and Tmux are always installed by bootstrap — no flags needed.
