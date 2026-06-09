#!/usr/bin/env bash

set -euo pipefail

readonly DOTFILES_ROOT="$HOME/.dotfiles"
readonly LOGS_DIR="$HOME/logs"
readonly TMUX_PLUGIN_DIR="$HOME/.tmux/plugins/tpm"
readonly CACHE_FILE="$LOGS_DIR/symlink_cache"

show_help() {
    cat << EOF
用法: $(basename "$0") [选项]

选项:
    -h, --help      显示帮助信息
    --with-tmux     包含 tmux 配置（默认跳过）
    --auto          自动模式，跳过交互式确认
    --parallel      启用并行下载优化
EOF
}

log_info() { printf "  [ \033[00;34m..\033[0m ] %s" "$1"; }
log_user() { printf "\r  [ \033[0;33m?\033[0m ] %s " "$1"; }
log_success() { printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"; }
log_error() { printf "\r\033[2K  [\033[0;31mFAIL\033[0m] %s\n" "$1"; echo ''; }

retry_command() {
    local cmd="$1" retries=3 timeout=30
    for ((i=1; i<=retries; i++)); do
        log_info "执行: $cmd (尝试 $i/$retries)\n"
        if timeout "$timeout" bash -c "$cmd"; then
            return 0
        fi
        if [[ $i -lt $retries ]]; then
            log_info "重试中...\n"
            sleep 2
        fi
    done
    log_error "命令执行失败: $cmd"
    return 1
}

check_prerequisites() {
    local missing_tools=()
    
    command -v git >/dev/null || missing_tools+=("git")
    command -v curl >/dev/null || missing_tools+=("curl")
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "缺少必要工具: ${missing_tools[*]}"
        log_info "请先安装这些工具\n"
        exit 1
    fi
}

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

install_prerequisites() {
    local platform=$1
    case "$platform" in
        Darwin) brew install git ;;
        Linux)  sudo apt update && sudo apt install -y git ;;
        Cygwin) pact install git ;;
    esac
}

link_file() {
    local src=$1 dst=$2
    local overwrite='' backup='' skip=''
    local action=''

    if [[ -f "$dst" || -d "$dst" || -L "$dst" ]]; then
        if [[ "$(readlink "$dst")" == "$src" ]]; then
            log_success "已存在正确的链接: $dst"
            return
        fi

        if [[ "$auto_mode" == "true" ]]; then
            log_success "自动模式: 跳过已存在文件 $dst"
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

    ln -sf "$src" "$dst"
    log_success "已创建链接: $src -> $dst"
}

setup_tmux() {
    if [[ ! -d "$TMUX_PLUGIN_DIR" ]]; then
        mkdir -p "$TMUX_PLUGIN_DIR"
        retry_command "git clone https://github.com/tmux-plugins/tpm '$TMUX_PLUGIN_DIR'"
    else
        retry_command "cd '$TMUX_PLUGIN_DIR' && git pull --rebase origin master"
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

    if [[ ! -f "$CACHE_FILE" || "$DOTFILES_ROOT" -nt "$CACHE_FILE" ]]; then
        log_info "扫描 symlink 文件...\n"
        mkdir -p "$(dirname "$CACHE_FILE")"
        
        case "$platform" in
            Darwin)
                find -H "$DOTFILES_ROOT" -maxdepth 3 \( -name "*.symlink" -o -name "*.macsymlink" \) > "$CACHE_FILE"
                ;;
            Linux)
                find -H "$DOTFILES_ROOT" -maxdepth 3 \( -name "*.symlink" -o -name "*.linuxsymlink" \) > "$CACHE_FILE"
                ;;
            Cygwin)
                find -H "$DOTFILES_ROOT" -maxdepth 3 \( -name "*.symlink" -o -name "*.winsymlink" \) > "$CACHE_FILE"
                ;;
        esac
        log_success "文件扫描完成，结果已缓存"
    else
        log_info "使用缓存的 symlink 文件列表\n"
    fi

    files_to_link=$(cat "$CACHE_FILE")

    if [[ -z "$files_to_link" ]]; then
        log_info "没有找到需要链接的文件\n"
        return
    fi

    while IFS= read -r src; do
        [[ -z "$src" ]] && continue
        local dst
        dst="$HOME/.$(basename "${src%.*}")"
        link_file "$src" "$dst"
    done <<< "$files_to_link"
}

main() {
    local platform skip_tmux=true auto_mode=false parallel_mode=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) show_help; exit 0 ;;
            --with-tmux) skip_tmux=false ;;
            --auto) auto_mode=true ;;
            --parallel) parallel_mode=true ;;
            *) log_error "未知选项: $1"; exit 1 ;;
        esac
        shift
    done

    check_prerequisites

    platform=$(detect_platform)
    install_prerequisites "$platform"

    mkdir -p "$LOGS_DIR"

    if [[ ! -d "$DOTFILES_ROOT" ]]; then
        log_info "首次安装 dotfiles...\n"
        retry_command "git clone https://github.com/jondong/dotfiles.git '$DOTFILES_ROOT'"
    else
        log_info "更新 dotfiles...\n"
        retry_command "cd '$DOTFILES_ROOT' && git pull --autostash --rebase origin master"
    fi
    install_dotfiles "$platform"

    if [[ "$skip_tmux" == "false" ]]; then
        setup_tmux
    fi

    log_success "配置完成!"
}

main "$@"
