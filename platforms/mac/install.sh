#!/usr/bin/env bash
#==============================================================================
# macOS 软件安装脚本
#==============================================================================

set -e

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
# 工具函数
#==============================================================================
log_info() {
    echo -e "\033[0;34m[INFO] $1\033[0m"
}

log_warn() {
    echo -e "\033[0;33m[WARN] $1\033[0m"
}

log_success() {
    echo -e "\033[0;32m[OK] $1\033[0m"
}

log_error() {
    echo -e "\033[0;31m[ERROR] $1\033[0m"
}

check_command() {
    command -v "$1" >/dev/null 2>&1
}

check_brew_package() {
    brew list "$1" >/dev/null 2>&1
}

check_brew_cask() {
    brew list --cask "$1" >/dev/null 2>&1
}

get_installed_packages() {
    local installed_formulae
    local installed_casks
    installed_formulae=$(brew list --formula)
    installed_casks=$(brew list --cask)
    echo "$installed_formulae $installed_casks"
}

#==============================================================================
# 包配置
#==============================================================================
if ((BASH_VERSINFO[0] < 4)) && [[ -z "${DOTFILES_BASH_REEXEC:-}" ]]; then
    for _b in /opt/homebrew/bin/bash /usr/local/bin/bash; do
        if [[ -x "$_b" ]] && "$_b" -c '((BASH_VERSINFO[0] >= 4))' 2>/dev/null; then
            export DOTFILES_BASH_REEXEC=1
            if [[ "$AUTO_MODE" == "true" ]]; then exec "$_b" "$0" --auto; else exec "$_b" "$0"; fi
        fi
    done
fi

if ((BASH_VERSINFO[0] < 4)); then
    echo "需要 bash 4.0 或更高版本"
    echo "当前 bash 版本: $BASH_VERSION"
    echo "请使用 Homebrew 安装最新版本的 bash："
    echo "brew install bash"
    exit 1
fi

declare -A PACKAGES

PACKAGES=(
    ["Basic"]="bash zsh reattach-to-user-namespace findutils"
    ["Utilities"]="neovim zellij ssh-copy-id wget tree autojump btop bat mas fd fzf ack prettyping mosh ncdu gdu tlrc rsync ripgrep highlight ca-certificates ccat duf the_silver_searcher fliqlo herdr"
    ["Fonts"]="freetype font-anonymice-nerd-font font-jetbrains-mono-nerd-font font-meslo-lg-nerd-font"
    ["DevTools"]="python3 uv poetry pipx jenv nvm rustup cmake shellcheck gitup yarn icdiff diff-so-fancy tokei openjdk openssl openssh krb5 imagemagick ios-deploy ideviceinstaller xcode-build-server xcbeautify swiftformat gh ghi gibo git-extras git-lfs git-open git-quick-stats sqlite docker lazydocker lazygit docker-compose direnv rbenv ruby-build"
    ["QuickLookPlugins"]="provisionql qlmarkdown quicklook-video"
    ["CLI"]="1password-cli"
    ["CaskTools"]="ghostty eudic muzzle the-unarchiver visual-studio-code android-studio"
)

#==============================================================================
# 安装函数
#==============================================================================
install_packages() {
    local category="$1"
    local -a packages
    IFS=' ' read -ra packages <<<"$2"
    local install_cmd="brew install"

    log_info "检查${category}..."

    if [[ "${category}" == "CaskTools" ]]; then
        install_cmd="${install_cmd} --cask"
    fi

    local installed_packages
    installed_packages=$(get_installed_packages)
    local missing_packages=()

    for package in "${packages[@]}"; do
        if ! echo "$installed_packages" | grep -q "\b${package}\b"; then
            missing_packages+=("$package")
        else
            log_success "$package 已安装"
        fi
    done

    if [ ${#missing_packages[@]} -gt 0 ]; then
        log_warn "安装缺失的包: ${missing_packages[*]}"
        if ! $install_cmd "${missing_packages[@]}"; then
            log_warn "部分包安装失败，请检查错误信息"
        fi
    else
        log_success "所有 ${category} 已安装"
    fi
}

setup_git() {
    log_info "配置 Git..."
    diff-so-fancy --set-defaults
}

#==============================================================================
# 主函数
#==============================================================================
main() {
    if ! check_command brew; then
        log_error "Homebrew 未安装，请先安装 Homebrew"
        exit 1
    fi

    # Update Homebrew (skip in auto mode for speed)
    if [[ "$AUTO_MODE" == "true" ]]; then
        log_info "Auto mode: 仅更新 Homebrew 索引..."
        brew update
    else
        log_info "更新 Homebrew..."
        brew update
        brew upgrade
    fi

    # 安装所有包
    for category in "${!PACKAGES[@]}"; do
        install_packages "$category" "${PACKAGES[$category]}"
    done

    # 配置开发环境
    setup_git

    # 清理
    log_info "清理旧版本..."
    brew cleanup

    log_success "所有工具检查和安装完成！"
}

main
