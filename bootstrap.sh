#!/usr/bin/env bash

set -euo pipefail  # 启用严格模式

# 常量定义
readonly DOTFILES_ROOT="$HOME/.dotfiles"
readonly LOGS_DIR="$HOME/logs"
readonly VIM_CONFIG_DIR="$HOME/.spf13-vim-3"
readonly TMUX_PLUGIN_DIR="$HOME/.tmux/plugins/tpm"

# 帮助文档
show_help() {
    cat << EOF
用法: $(basename "$0") [选项]

选项:
    -h, --help     显示帮助信息
    --skip-vim     跳过vim配置
    --skip-tmux    跳过tmux配置
EOF
}

# 日志函数
log_info() { printf "  [ \033[00;34m..\033[0m ] %s" "$1"; }
log_user() { printf "\r  [ \033[0;33m?\033[0m ] %s " "$1"; }
log_success() { printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"; }
log_error() { printf "\r\033[2K  [\033[0;31mFAIL\033[0m] %s\n" "$1"; echo ''; }

# 检测系统平台
detect_platform() {
    local platform_name
    platform_name=$(uname)
    case "${platform_name:0:6}" in
        Darwin) echo "Darwin" ;;
        Linux)  echo "Linux" ;;
        CYGWIN) echo "Cygwin" ;;
        *)      log_error "不支持的平台: $platform_name"; exit 1 ;;
    esac
}

# 安装必要的包
install_prerequisites() {
    local platform=$1
    case "$platform" in
        Darwin) brew install git vim ;;
        Linux)  sudo apt update && sudo apt install -y git vim ;;
        Cygwin) pact install git vim ;;
    esac
}

link_file() {
    local src=$1 dst=$2
    local overwrite='' backup='' skip=''
    local action=''

    # 如果目标已存在
    if [[ -f "$dst" || -d "$dst" || -L "$dst" ]]; then
        # 如果已经是正确的软链接，跳过
        if [[ "$(readlink "$dst")" == "$src" ]]; then
            log_success "已存在正确的链接: $dst"
            return
        fi

        if [[ "$overwrite_all" == "false" && "$backup_all" == "false" && "$skip_all" == "false" ]]; then
            log_user "文件已存在: $dst ($(basename "$src")), 请选择操作:\n\
            [s]跳过 [S]全部跳过 [o]覆盖 [O]全部覆盖 [b]备份 [B]全部备份"
            read -r -n 1 action
            echo

            case "$action" in
                o) overwrite=true ;;
                O) overwrite_all=true ;;
                b) backup=true ;;
                B) backup_all=true ;;
                s) skip=true ;;
                S) skip_all=true ;;
                *) skip=true ;;
            esac
        fi

        overwrite=${overwrite:-$overwrite_all}
        backup=${backup:-$backup_all}
        skip=${skip:-$skip_all}

        if [[ "$overwrite" == "true" ]]; then
            rm -rf "$dst"
            log_success "已删除: $dst"
        fi

        if [[ "$backup" == "true" ]]; then
            mv "$dst" "${dst}.backup"
            log_success "已备份: $dst -> ${dst}.backup"
        fi

        if [[ "$skip" == "true" ]]; then
            log_success "已跳过: $src"
            return
        fi
    fi

    # 创建软链接
    ln -sf "$src" "$dst"
    log_success "已创建链接: $src -> $dst"
}

setup_vim() {
    if [[ ! -d "$VIM_CONFIG_DIR" ]]; then
        log_info "安装 vim 配置...\n"
        curl -fsSL https://j.mp/spf13-vim3 | sh
    else
        log_info "更新 vim 配置...\n"
        curl -fsSL https://j.mp/spf13-vim3 -o - | sh
    fi
    log_success "Vim 配置完成"
}

# 安装 Tmux 配置
setup_tmux() {
    if [[ ! -d "$TMUX_PLUGIN_DIR" ]]; then
        mkdir -p "$TMUX_PLUGIN_DIR"
        git clone https://github.com/tmux-plugins/tpm "$TMUX_PLUGIN_DIR"
    else
        (cd "$TMUX_PLUGIN_DIR" && git pull --rebase origin master)
    fi
    tmux source "$HOME/.tmux.conf" 2>/dev/null || true
    log_success "Tmux 配置完成"
}

install_dotfiles() {
    log_info "开始安装 dotfiles...\n"
    
    local overwrite_all backup_all skip_all
    overwrite_all=false
    backup_all=false
    skip_all=false
    
    local platform=$1
    
    local files_to_link
    files_to_link=""
    
    # 根据平台选择要链接的文件
    case "$platform" in
        Darwin) 
            files_to_link=$(find -H "$DOTFILES_ROOT" -maxdepth 3 -name "*.symlink" -o -name "*.macsymlink")
            ;;
        Linux)
            files_to_link=$(find -H "$DOTFILES_ROOT" -maxdepth 3 -name "*.symlink" -o -name "*.linuxsymlink")
            ;;
        Cygwin)
            files_to_link=$(find -H "$DOTFILES_ROOT" -maxdepth 3 -name "*.symlink" -o -name "*.winsymlink")
            ;;
    esac

    # 如果没有找到文件，提前返回
    if [[ -z "$files_to_link" ]]; then
        log_info "没有找到需要链接的文件\n"
        return
    fi

    # 处理每个找到的文件
    for src in $files_to_link; do
        # 移除扩展名作为目标文件名
        local dst
        dst="$HOME/.$(basename "${src%.*}")"
        link_file "$src" "$dst"
    done
}

# 主函数
main() {
    local platform skip_vim=false skip_tmux=false
    
    # 参数解析
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) show_help; exit 0 ;;
            --skip-vim) skip_vim=true ;;
            --skip-tmux) skip_tmux=true ;;
            *) log_error "未知选项: $1"; exit 1 ;;
        esac
        shift
    done
    
    platform=$(detect_platform)
    install_prerequisites "$platform"
    
    # 创建日志目录
    mkdir -p "$LOGS_DIR"
    
    # 安装/更新 dotfiles
    if [[ ! -d "$DOTFILES_ROOT" ]]; then
        log_info "首次安装 dotfiles...\n"
        git clone https://github.com/jondong/dotfiles.git "$DOTFILES_ROOT"
    else
        log_info "更新 dotfiles...\n"
        (cd "$DOTFILES_ROOT" && \
            git stash && \
            git pull --rebase origin master && \
            git stash pop || true)
    fi
    install_dotfiles "$platform"
    
    # 配置 Vim
    if ! $skip_vim; then
        read -rp "配置 Vim? [Y/n]: " -n 1 reply
        [[ ${reply:-y} =~ ^[Yy]$ ]] && setup_vim
    fi
    
    # 配置 Tmux
    if ! $skip_tmux; then
        read -rp "配置 Tmux? [Y/n]: " -n 1 reply
        [[ ${reply:-y} =~ ^[Yy]$ ]] && setup_tmux
    fi
    
    log_success "配置完成!"
}

main "$@"

