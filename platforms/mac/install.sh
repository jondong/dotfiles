#!/usr/bin/env bash
#==============================================================================
# macOS 软件安装脚本
#==============================================================================

set -e  # 遇到错误立即退出

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

# 检查命令是否存在
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# 检查 Homebrew 包是否已安装
check_brew_package() {
    brew list "$1" >/dev/null 2>&1
}

# 检查 Homebrew Cask 包是否已安装
check_brew_cask() {
    brew list --cask "$1" >/dev/null 2>&1
}

#==============================================================================
# Homebrew 更新
#==============================================================================
update_homebrew() {
    log_info "更新 Homebrew..."
    brew update
    brew upgrade
}

#==============================================================================
# 包配置
#==============================================================================
declare -A PACKAGES=(
    ["基础工具"]="bash zsh bash-completion2 bash-git-prompt zsh-completions reattach-to-user-namespace antigen findutils"

    ["实用工具"]="nvim tmux zellij ssh-copy-id wget tree autojump ag btop bat mas z fd fzf ack prettyping mosh ncdu tldr trash rsync ripgrep highlight ca-certificates ccat duf the_silver_searcher"

    ["字体"]="freetype font-anonymice-nerd-font font-jetbrains-mono-nerd-font"

    ["开发工具"]="pyenv pyenv-virtualenv jenv nvm rustup cmake shellcheck gitup mobile-shell ghi yarn icdiff diff-so-fancy tokei openjdk openssl openssh krb5 imagemagick ios-deploy ideviceinstaller cocoapods gh ghi gibo git-extras git-flow git-lfs git-open git-quick-stats sqlite"

    ["QuickLook插件"]="provisionql qlimagesize qlmarkdown qlprettypatch qlvideo quicklook-json webpquicklook fliqlo"

    ["CLI工具"]="1password-cli"

    ["Cask应用"]="--cask cheatsheet dash eudic muzzle the-unarchiver visual-studio-code warp"
)

#==============================================================================
# 安装函数
#==============================================================================
install_packages() {
    local category=$1
    local packages=($2)  # 将字符串转换为数组
    local install_cmd="brew install"

    log_info "检查${category}..."

    for package in "${packages[@]}"; do
        if [[ "$package" == "--cask" ]]; then
            install_cmd="brew install --cask"
            continue
        fi

        if ! check_brew_package "$package"; then
            log_warn "安装 $package..."
            $install_cmd "$package"
        else
            log_success "$package 已安装"
        fi
    done
}

#==============================================================================
# 主函数
#==============================================================================
main() {
    # 检查 Homebrew
    if ! check_command brew; then
        log_error "Homebrew 未安装，请先安装 Homebrew"
        exit 1
    fi

    # 更新 Homebrew
    log_info "更新 Homebrew..."
    brew update
    brew upgrade

    # 安装所有包
    for category in "${!PACKAGES[@]}"; do
        install_packages "$category" "${PACKAGES[$category]}"
    done

    # 配置开发环境
    setup_fzf
    setup_pyenv
    setup_git

    # 清理
    log_info "清理旧版本..."
    brew cleanup

    log_success "所有工具检查和安装完成！"
}

# 执行主函数
main
