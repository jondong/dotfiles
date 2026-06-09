#!/usr/bin/env bash
set -euo pipefail

#==============================================================================
# Linux Dotfiles Installation Script
# Supports Debian/Ubuntu-based systems only.
#==============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_ok()   { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*" >&2; }
log_err()  { echo -e "${RED}[ERR]${NC} $*" >&2; }

#==============================================================================
# Argument parsing
#==============================================================================
AUTO_MODE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --auto)
            AUTO_MODE=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

#==============================================================================
# Pre-flight checks
#==============================================================================

if ! command -v apt-get &>/dev/null; then
    log_err "This script only supports Debian/Ubuntu-based systems."
    exit 1
fi

log_info "Installing packages for development machine."

#==============================================================================
# Package lists
#==============================================================================

core_packages=(
    neovim git autojump xclip xsel ssh tree openssl unzip curl tar zsh
    exfat-fuse eza bat fd-find pipx python3-pip python3-venv
    findutils ack duf
    fcitx5 fcitx5-rime fcitx5-configtool rime-data-double-pinyin
)

dev_packages=(
    git-extras git-lfs git-flow gh shellcheck cmake alacritty mosh
    ruby ruby-dev source-highlight expect cgdb valgrind clang global
    cscope exuberant-ctags net-tools ncdu gdu ripgrep gnome-tweaks
    rustup btop highlight fonts-jetbrains-mono fonts-firacode fonts-hack
    rbenv ruby-build direnv icdiff
)

#==============================================================================
# Helper functions
#==============================================================================

install_apt_package() {
    local pkg="$1"
    if dpkg -l "$pkg" &>/dev/null | grep -q "^ii"; then
        log_ok "$pkg is already installed."
        return 0
    fi
    if sudo apt-get install -y "$pkg" >/dev/null 2>&1; then
        log_ok "Installed $pkg"
    else
        log_warn "Failed to install $pkg (may not exist in apt)"
        return 1
    fi
}

install_prettyping() {
    if command -v prettyping &>/dev/null; then
        log_ok "prettyping is already installed."
        return 0
    fi
    log_info "Installing prettyping from GitHub..."
    mkdir -p "$HOME/.local/bin"
    if curl -fsSL https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping -o "$HOME/.local/bin/prettyping"; then
        chmod +x "$HOME/.local/bin/prettyping"
        log_ok "Installed prettyping to ~/.local/bin/"
    else
        log_warn "Failed to download prettyping. Skipping."
    fi
}

install_docker_compose() {
    if command -v docker-compose &>/dev/null; then
        log_ok "docker-compose is already installed."
        return 0
    fi
    log_info "Installing docker-compose from GitHub release..."
    mkdir -p "$HOME/.local/bin"

    local release_url
    release_url=$(curl -fsSL https://api.github.com/repos/docker/compose/releases/latest 2>/dev/null \
        | grep -oP 'https://github.com/docker/compose/releases/download/[^"]+/docker-compose-linux-x86_64' \
        | head -1)

    if [[ -z "$release_url" ]]; then
        log_warn "Could not determine latest docker-compose release URL. Skipping."
        return 1
    fi

    if curl -fsSL "$release_url" -o "$HOME/.local/bin/docker-compose"; then
        chmod +x "$HOME/.local/bin/docker-compose"
        log_ok "Installed docker-compose to ~/.local/bin/"
    else
        log_warn "Failed to download docker-compose. Skipping."
        return 1
    fi
}

install_lazydocker() {
    if command -v lazydocker &>/dev/null; then
        log_ok "lazydocker is already installed."
        return 0
    fi
    log_info "Installing lazydocker..."
    local tmpfile
    tmpfile=$(mktemp)
    trap "rm -f '$tmpfile'" EXIT

    if curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh -o "$tmpfile"; then
        bash "$tmpfile"
        log_ok "Installed lazydocker"
    else
        log_warn "Failed to download lazydocker install script. Skipping."
    fi
}

#==============================================================================
# System update & optional cleanup
#==============================================================================

if [[ "$AUTO_MODE" == "true" ]]; then
    log_info "Auto mode: skipping LibreOffice removal prompt"
else
    read -e -p "Remove LibreOffice? [y/N] " -n 1
    echo
    remove_libreoffice=${REPLY:=n}
    remove_libreoffice=${remove_libreoffice,,}

    if [[ "$remove_libreoffice" == "y" ]]; then
        log_info "Removing LibreOffice..."
        sudo apt-get -y remove libreoffice-core libreoffice-base-core libreoffice-common || log_warn "Some LibreOffice packages were not found"
        sudo apt-get -y autoremove || true
    fi
fi

log_info "Updating package lists and upgrading system..."
sudo apt-get -y update
sudo apt-get -y upgrade

#==============================================================================
# Install apt packages
#==============================================================================

log_info "Installing core packages..."
for pkg in "${core_packages[@]}"; do
    install_apt_package "$pkg" || true
done

install_prettyping

log_info "Installing development packages..."
for pkg in "${dev_packages[@]}"; do
    install_apt_package "$pkg" || true
done

install_docker_compose

#==============================================================================
# Post-install: fix binary names for bat and fd
#==============================================================================

if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    log_ok "Created symlink: fd -> fdfind"
fi

if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    log_ok "Created symlink: bat -> batcat"
fi

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

#==============================================================================
# Install snap packages
#==============================================================================

log_info "Installing snap packages..."
sudo snap install --classic zellij || log_warn "Failed to install zellij via snap"
sudo snap install diff-so-fancy || log_warn "Failed to install diff-so-fancy via snap"

#==============================================================================
# Install Python tools with pipx
#==============================================================================

log_info "Installing Python tools via pipx..."
pipx install gitup uv poetry || log_warn "Some pipx installations failed"
pipx ensurepath >/dev/null 2>&1 || true

#==============================================================================
# Install Rust toolchain and cargo apps
#==============================================================================

log_info "Setting up Rust..."
if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi

if command -v rustup &>/dev/null; then
    rustup default stable || log_warn "Failed to set rustup default"
    if command -v cargo &>/dev/null; then
        cargo install tokei || log_warn "Failed to install tokei via cargo"
    else
        log_warn "cargo not found in PATH. Skipping cargo installs."
    fi
else
    log_warn "rustup not found. Skipping Rust setup."
fi

#==============================================================================
# Install fzf (non-interactive)
#==============================================================================

if [[ ! -d ~/.fzf ]]; then
    log_info "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
fi

if [[ -d ~/.fzf ]]; then
    log_info "Running fzf installer (non-interactive)..."
    ~/.fzf/install --all --no-bash --no-fish || log_warn "fzf install script had issues"
fi

#==============================================================================
# Install pyenv
#==============================================================================

if [[ ! -d ~/.pyenv ]]; then
    log_info "Installing pyenv..."
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
    log_ok "pyenv cloned to ~/.pyenv"
else
    log_ok "pyenv already installed."
fi

#==============================================================================
# Install jenv
#==============================================================================

if [[ ! -d ~/.jenv ]]; then
    log_info "Installing jenv..."
    git clone https://github.com/jenv/jenv.git ~/.jenv
    log_ok "jenv cloned to ~/.jenv"
else
    log_ok "jenv already installed."
fi

#==============================================================================
# Install nvm
#==============================================================================

if [[ ! -d ~/.nvm ]]; then
    log_info "Installing nvm..."
    git clone https://github.com/nvm-sh/nvm.git ~/.nvm
    log_ok "nvm cloned to ~/.nvm"
else
    log_ok "nvm already installed."
fi

#==============================================================================
# Install lazydocker
#==============================================================================

install_lazydocker

#==============================================================================
# Setup crontab
#==============================================================================

if [[ -f "$HOME/.crontab" ]]; then
    log_info "Setting up crontab from ~/.crontab..."
    crontab "$HOME/.crontab"
    log_ok "Crontab installed."
else
    if [[ "$VERBOSE" == "true" ]]; then
        log_warn "No ~/.crontab found. Skipping crontab setup."
    fi
fi

#==============================================================================
# Done
#==============================================================================

log_info "Installation complete!"
log_info "You may need to restart your shell or run 'source ~/.zshrc' for all changes to take effect."
