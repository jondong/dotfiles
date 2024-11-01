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
# 安装软件包
#==============================================================================
install_base_tools() {
    log_info "检查基础系统工具..."
    local tools=(
        "bash"
        "zsh"
        "bash-completion2"
        "bash-git-prompt"
        "zsh-completions"
        "reattach-to-user-namespace"
        "antigen"
        "findutils"
    )

    for tool in "${tools[@]}"; do
        if ! check_brew_package "$tool"; then
            log_warn "安装 $tool..."
            brew install "$tool"
        else
            log_success "$tool 已安装"
        fi
    done
}

install_utilities() {
    log_info "检查实用工具..."
    local utils=(
        "nvim" "tmux" "zellij" "ssh-copy-id" "wget" "tree" "autojump" 
        "ag" "btop" "bat" "mas" "z" "fd" "fzf" "ack" "prettyping" 
        "mosh" "ncdu" "tldr" "trash" "rsync" "ripgrep" "highlight" 
        "ca-certificates" "ccat" "duf" "the_silver_searcher"
    )

    for util in "${utils[@]}"; do
        if ! check_brew_package "$util"; then
            log_warn "安装 $util..."
            brew install "$util"
        else
            log_success "$util 已安装"
        fi
    done
}

install_fonts() {
    log_info "检查字体..."
    local fonts=(
        "freetype"
        "font-anonymice-nerd-font"
        "font-jetbrains-mono-nerd-font"
    )

    for font in "${fonts[@]}"; do
        if ! check_brew_package "$font"; then
            log_warn "安装 $font..."
            brew install "$font"
        else
            log_success "$font 已安装"
        fi
    done
}

install_dev_tools() {
    log_info "检查开发工具..."
    local dev_tools=(
        "pyenv" "pyenv-virtualenv" "jenv" "nvm" "rustup" "cmake" "shellcheck"
        "gitup" "mobile-shell" "ghi" "yarn" "icdiff" "diff-so-fancy" "tokei"
        "openjdk" "openssl" "openssh" "krb5" "imagemagick" "ios-deploy"
        "ideviceinstaller" "cocoapods" "gh" "ghi" "gibo" "git-extras"
        "git-flow" "git-lfs" "git-open" "git-quick-stats" "sqlite"
    )

    for tool in "${dev_tools[@]}"; do
        if ! check_brew_package "$tool"; then
            log_warn "安装 $tool..."
            brew install "$tool"
        else
            log_success "$tool 已安装"
        fi
    done
}

install_quicklook() {
    log_info "检查 QuickLook 插件..."
    local plugins=(
        "provisionql"
        "qlimagesize"
        "qlmarkdown"
        "qlprettypatch"
        "qlvideo"
        "quicklook-json"
        "webpquicklook"
        "fliqlo"
    )

    for plugin in "${plugins[@]}"; do
        if ! check_brew_package "$plugin"; then
            log_warn "安装 $plugin..."
            brew install "$plugin"
        else
            log_success "$plugin 已安装"
        fi
    done
}

install_apps() {
    log_info "检查应用程序..."

    # 检查 CLI 工具
    if ! check_brew_package "1password-cli"; then
        log_warn "安装 1password-cli..."
        brew install 1password-cli
    else
        log_success "1password-cli 已安装"
    fi

    # 检查 Cask 应用
    local casks=(
        "cheatsheet"
        "dash"
        "eudic"
        "muzzle"
        "the-unarchiver"
        "visual-studio-code"
        "warp"
    )

    for cask in "${casks[@]}"; do
        if ! check_brew_cask "$cask"; then
            log_warn "安装 $cask..."
            brew install --cask "$cask"
        else
            log_success "$cask 已安装"
        fi
    done
}

#==============================================================================
# 配置开发环境
#==============================================================================
setup_fzf() {
    if [[ ! -f ~/.fzf.zsh ]]; then
        log_info "配置 FZF..."
        "$(brew --prefix)/opt/fzf/install" --all
    else
        log_success "FZF 已配置"
    fi
}

setup_pyenv() {
    log_info "检查 Python 环境..."
    local versions=("2.7.18" "3.10.15")

    for version in "${versions[@]}"; do
        if ! pyenv versions | grep -q "$version"; then
            log_warn "安装 Python $version..."
            pyenv install "$version"
        else
            log_success "Python $version 已安装"
        fi
    done

    pyenv global "${versions[@]}"
}

setup_git() {
    log_info "配置 Git..."
    diff-so-fancy --set-defaults
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

    # 检查并安装软件包
    install_base_tools
    install_utilities
    install_fonts
    install_dev_tools
    install_quicklook
    install_apps

    # 检查并配置开发环境
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
