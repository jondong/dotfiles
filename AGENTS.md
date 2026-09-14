# AGENTS.md

This file provides guidance to Agent tools (Codex/Claude Code, etc.) when working with code in this repository.

## Repository Overview

Personal dotfiles management for Linux and macOS development environments. A single bootstrap script sets up the entire environment.

## Directory Structure

```
dotfiles/
├── apps/                        # App configs, linked by bootstrap setup_* (not the symlink scan)
│   ├── ghostty/config.ghostty   # → XDG path (Linux) + Application Support & XDG (macOS)
│   ├── herdr/config.toml        # → ~/.config/herdr/config.toml
│   └── tmux/                    # tmux.conf.symlink, tmux-osx.conf.macsymlink
├── bin/                         # Utility scripts, on PATH (tmux-*/herdr-launcher, encrypt-zip, git-global, …)
├── platforms/
│   ├── linux/
│   │   ├── install.sh           # apt-based package installation
│   │   └── aliases.zsh
│   └── mac/
│       ├── install.sh           # Homebrew-based package installation
│       └── aliases.zsh
├── scripts/
│   ├── doctor.sh                # Configuration health check & repair
│   └── test-linux-config.sh     # Linux config smoke test (CI; requires Linux)
├── shells/zsh/                  # Zsh configuration (split by platform)
│   ├── common/                  # base, functions, paths, aliases, fzf, lazyload, dev-tools, final, machine-identity
│   ├── linux/                   # Linux-specific env, path, tools
│   ├── mac/                     # macOS-specific env, path, tools
│   ├── zshrc.symlink
│   ├── zprofile.symlink
│   ├── zshenv.symlink
│   └── p10k.zsh.symlink
├── .github/workflows/linux-config.yml   # CI (see Testing below)
├── bootstrap.sh                 # Single entry point
└── README.md
```

## Symlink Naming Convention

- `.symlink` — universal, deployed on all platforms
- `.macsymlink` — macOS only
- `.linuxsymlink` — Linux only
- Suffix-less files in `apps/` (ghostty, herdr) are NOT picked up by the symlink scan; `setup_ghostty`/`setup_herdr` in `bootstrap.sh` link them directly to the app config paths.

## Common Commands

### Initial Setup

```bash
# Minimal: clone, symlinks, zsh, tmux + ghostty/herdr config links
bash <(curl https://raw.githubusercontent.com/jondong/dotfiles/master/bootstrap.sh -L)

# Full automated: everything including system packages
./bootstrap.sh --with-packages --auto
```

### Testing Configuration Changes

```bash
source ~/.zshrc                  # local shell changes

# CI gate: keep these files shellcheck-clean
shellcheck bootstrap.sh scripts/doctor.sh platforms/linux/install.sh \
  bin/herdr-launcher scripts/test-linux-config.sh

scripts/test-linux-config.sh     # Linux only (errors out elsewhere); simulates a fresh HOME
```

### Health Check & Repair

```bash
./scripts/doctor.sh           # interactive
./scripts/doctor.sh --auto    # auto-fix
```

## Key Patterns

### Platform Detection

`bootstrap.sh` detects OS via `uname` and selects appropriate configs. Shell configs use `$PLATFORM` (set in zprofile) to load platform-specific files.

### Zsh Loading Chain

```
zshenv    →    zprofile     →    zshrc
  ↓                ↓                ↓
env vars,   PLATFORM,      base → functions → paths
machine-    DOTFILES_ROOT,     ↓
identity,   proxyrc/       platform: env/path/tools (+ platforms/<plat>/aliases.zsh)
p10k        localrc            ↓
                             aliases → fzf → lazyload → dev-tools → final
```

### Performance

- Zinit with `light-mode` and lazy loading for plugins
- NVM, rbenv, jenv, direnv are lazy-loaded
- `TERM_PROGRAM` instead of `ps` for terminal detection

### Mandatory Components

Phase 1 of bootstrap always runs (no flags): installs Zsh + Tmux when missing (brew/apt, TPM plugins), links Ghostty + Herdr configs. `--with-packages` is opt-in; `--skip-health` / `--skip-update` opt out of doctor / git pull.

### CI

`.github/workflows/linux-config.yml` (push/PR): `bash -n` + `shellcheck` over bootstrap.sh, scripts/doctor.sh, platforms/linux/install.sh, bin/herdr-launcher, scripts/test-linux-config.sh; runs test-linux-config.sh; validates the Herdr config with the installed herdr binary.
