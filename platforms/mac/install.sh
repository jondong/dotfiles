#!/usr/bin/env bash
#==============================================================================
# macOS 软件安装脚本
#==============================================================================

set -e # 遇到错误立即退出

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

# 获取所有已安装的包（包括 cask）
get_installed_packages() {
    # 获取所有已安装的包（包括 cask）
    local installed_formulae
    local installed_casks
    installed_formulae=$(brew list --formula)
    installed_casks=$(brew list --cask)
    echo "$installed_formulae $installed_casks"
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
    ["Basic"]="bash zsh zsh-completions reattach-to-user-namespace antigen findutils"

    ["Utilities"]="neovim tmux zellij ssh-copy-id wget tree autojump btop bat mas z fd fzf ack prettyping mosh ncdu tldr trash rsync ripgrep highlight ca-certificates ccat duf the_silver_searcher fliqlo"

    ["Fonts"]="freetype font-anonymice-nerd-font font-jetbrains-mono-nerd-font"

    ["DevTools"]="pyenv pyenv-virtualenv jenv nvm rustup cmake shellcheck gitup ghi yarn icdiff diff-so-fancy tokei openjdk openssl openssh krb5 imagemagick ios-deploy ideviceinstaller cocoapods gh ghi gibo git-extras git-flow git-lfs git-open git-quick-stats sqlite lazydocker docker-compose"

    ["QuickLookPlugins"]="provisionql qlimagesize qlmarkdown qlprettypatch qlvideo quicklook-json webpquicklook"

    ["CLI"]="1password-cli"

    ["CaskTools"]="cheatsheet dash eudic hyper alacritty muzzle the-unarchiver visual-studio-code warp docker android-studio lm-studio"
)

#==============================================================================
# 安装函数
#==============================================================================
install_packages() {
    local category="$1"
    local -a packages
    # 使用 read -ra 更安全地将字符串拆分为数组
    IFS=' ' read -ra packages <<<"$2"
    local install_cmd="brew install"

    log_info "检查${category}..."

    # 检查是否为 cask 包类别
    if [[ "${category}" == "CaskTools" ]]; then
        install_cmd="${install_cmd} --cask"
    fi

    # 获取所有已安装的包
    local installed_packages
    installed_packages=$(get_installed_packages)
    local missing_packages=()

    # 检查哪些包需要安装
    for package in "${packages[@]}"; do
        if ! echo "$installed_packages" | grep -q "\b${package}\b"; then
            missing_packages+=("$package")
        else
            log_success "$package 已安装"
        fi
    done

    # 批量安装缺失的包
    if [ ${#missing_packages[@]} -gt 0 ]; then
        log_warn "安装缺失的包: ${missing_packages[*]}"
        if ! $install_cmd "${missing_packages[@]}"; then
            log_warn "部分包安装失败，请检查错误信息"
        fi
    else
        log_success "所有 ${category} 已安装"
    fi
}

#==============================================================================
# 配置函数
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

setup_alacritty() {
    local config_dir="$HOME/.config/alacritty"
    local theme_dir="$config_dir/themes"
    local theme_repo="https://github.com/alacritty/alacritty-theme.git"

    log_info "配置 Alacritty..."

    # 检查配置目录是否存在
    if [ ! -d "$config_dir" ]; then
        log_info "创建 Alacritty 配置目录..."
        mkdir -p "$config_dir"
    fi

    # 检查主题目录是否存在
    if [ ! -d "$theme_dir" ]; then
        log_info "克隆 Alacritty 主题..."
        git clone "$theme_repo" "$theme_dir"
    else
        log_info "更新 Alacritty 主题..."
        git -C "$theme_dir" pull
    fi

    log_success "Alacritty 配置完成"
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
    setup_alacritty

    # 清理
    log_info "清理旧版本..."
    brew cleanup

    log_success "所有工具检查和安装完成！"
}

# 执行主函数
main
