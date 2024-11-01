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

log_error() {
    echo -e "\033[0;31m[ERROR] $1\033[0m"
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
    log_info "安装基础系统工具..."
    brew install \
        bash \
        zsh \
        bash-completion2 \
        bash-git-prompt \
        zsh-completions \
        reattach-to-user-namespace \
        antigen \
        findutils
}

install_utilities() {
    log_info "安装实用工具..."
    brew install \
        nvim tmux zellij ssh-copy-id wget tree autojump ag btop bat \
        mas z fd fzf ack prettyping mosh ncdu tldr trash rsync \
        ripgrep highlight ca-certificates ccat duf the_silver_searcher
}

install_fonts() {
    log_info "安装字体..."
    brew install \
        freetype \
        font-anonymice-nerd-font \
        font-jetbrains-mono-nerd-font
}

install_dev_tools() {
    log_info "安装开发工具..."
    brew install \
        pyenv pyenv-virtualenv jenv nvm rustup cmake shellcheck \
        gitup mobile-shell ghi yarn icdiff diff-so-fancy tokei openjdk \
        openssl openssh krb5 imagemagick ios-deploy ideviceinstaller \
        cocoapods gh ghi gibo git-extras git-flow git-lfs git-open \
        git-quick-stats sqlite
}

install_quicklook() {
    log_info "安装 QuickLook 插件..."
    brew install \
        provisionql qlimagesize qlmarkdown qlprettypatch \
        qlvideo quicklook-json webpquicklook fliqlo
}

install_apps() {
    log_info "安装应用程序..."
    brew install 1password-cli
    brew install --cask \
        cheatsheet \
        dash \
        eudic \
        muzzle \
        the-unarchiver \
        visual-studio-code \
        warp
}

#==============================================================================
# 配置开发环境
#==============================================================================
setup_fzf() {
    log_info "配置 FZF..."
    "$(brew --prefix)/opt/fzf/install"
}

setup_pyenv() {
    log_info "配置 Python 环境..."
    local pyenv_versions="2.7.18 3.10.15"
    pyenv install $pyenv_versions
    pyenv global $pyenv_versions
}

setup_git() {
    log_info "配置 Git..."
    diff-so-fancy --set-defaults
}

#==============================================================================
# 主函数
#==============================================================================
main() {
    # 更新 Homebrew
    update_homebrew

    # 安装软件包
    install_base_tools
    install_utilities
    install_fonts
    install_dev_tools
    install_quicklook
    install_apps

    # 配置开发环境
    setup_fzf
    setup_pyenv
    setup_git

    # 清理
    log_info "清理旧版本..."
    brew cleanup

    log_info "安装完成！"
}

# 执行主函数
main

