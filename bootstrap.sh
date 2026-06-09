#!/usr/bin/env bash

set -euo pipefail

#==============================================================================
# Constants
#==============================================================================
readonly DOTFILES_ROOT="$HOME/.dotfiles"
readonly DOTFILES_REPO="https://github.com/jondong/dotfiles.git"
readonly LOGS_DIR="$HOME/logs"
readonly TMUX_PLUGIN_DIR="$HOME/.tmux/plugins/tpm"
readonly CACHE_FILE="$LOGS_DIR/symlink_cache"

#==============================================================================
# State
#==============================================================================
AUTO_MODE=false
VERBOSE=false
WITH_PACKAGES=false
ENVIRONMENT=""
SKIP_HEALTH=false
SKIP_UPDATE=false

#==============================================================================
# Help
#==============================================================================
show_help() {
    cat << EOF
用法: $(basename "$0") [选项]

一键式 dotfiles 安装脚本

基础选项:
    -h, --help              显示帮助
    --auto                  自动模式，跳过所有交互确认
    -v, --verbose           详细输出

安装组件:
    --with-packages         运行平台包安装脚本 (platforms/*/install.sh)
    --env ENV               应用开发环境模板 (web/backend/mobile/data-science/devops)

高级选项:
    --skip-health           跳过安装后健康检查
    --skip-update           跳过 git pull 更新

示例:
    bootstrap.sh --auto
    bootstrap.sh --with-packages --auto
    bootstrap.sh --env web --with-packages --auto
EOF
}

#==============================================================================
# Logging
#==============================================================================
log_info()    { printf "  [ \033[00;34m..\033[0m ] %s\n" "$1"; }
log_user()    { printf "\r  [ \033[0;33m?\033[0m ] %s " "$1"; }
log_success() { printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"; }
log_error()   { printf "\r\033[2K  [\033[0;31mFAIL\033[0m] %s\n" "$1"; echo ''; }
log_warn()    { printf "  [ \033[0;33m!!\033[0m ] %s\n" "$1"; }

#==============================================================================
# Retry mechanism
#==============================================================================
retry_command() {
    local cmd="$1" retries=3 timeout=30
    for ((i=1; i<=retries; i++)); do
        if [[ "$VERBOSE" == "true" ]]; then
            log_info "执行: $cmd (尝试 $i/$retries)"
        fi
        if timeout "$timeout" bash -c "$cmd"; then
            return 0
        fi
        if [[ $i -lt $retries ]]; then
            log_info "重试中..."
            sleep 2
        fi
    done
    log_error "命令执行失败: $cmd"
    return 1
}

#==============================================================================
# Prerequisites check
#==============================================================================
check_prerequisites() {
    local missing_tools=()
    
    command -v git >/dev/null || missing_tools+=("git")
    command -v curl >/dev/null || missing_tools+=("curl")
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "缺少必要工具: ${missing_tools[*]}"
        log_info "请先安装这些工具"
        exit 1
    fi
}

#==============================================================================
# Platform detection
#==============================================================================
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

#==============================================================================
# Clone or update repository
#==============================================================================
clone_or_update() {
    if [[ ! -d "$DOTFILES_ROOT" ]]; then
        log_info "首次安装 dotfiles..."
        retry_command "git clone '$DOTFILES_REPO' '$DOTFILES_ROOT'"
    else
        if [[ "$SKIP_UPDATE" == "true" ]]; then
            log_info "跳过 git 更新 (--skip-update)"
        else
            log_info "更新 dotfiles..."
            retry_command "cd '$DOTFILES_ROOT' && git pull --autostash --rebase origin master"
        fi
    fi
}

#==============================================================================
# Symlink management
#==============================================================================
link_file() {
    local src=$1 dst=$2
    local overwrite='' backup='' skip=''
    local action=''

    if [[ -f "$dst" || -d "$dst" || -L "$dst" ]]; then
        if [[ "$(readlink "$dst")" == "$src" ]]; then
            log_success "已存在正确的链接: $dst"
            return
        fi

        if [[ "$AUTO_MODE" == "true" ]]; then
            log_success "自动模式: 跳过已存在文件 $dst"
            return
        fi

        if [[ "$overwrite_all" == "false" && "$backup_all" == "false" && "$skip_all" == "false" ]]; then
            log_user "文件已存在: $dst ($(basename "$src")), 请选择操作:
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

install_dotfiles() {
    log_info "开始安装 dotfiles..."

    local platform=$1
    overwrite_all=false
    backup_all=false
    skip_all=false

    local files_to_link=""

    if [[ ! -f "$CACHE_FILE" || "$DOTFILES_ROOT" -nt "$CACHE_FILE" ]]; then
        log_info "扫描 symlink 文件..."
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
        if [[ "$VERBOSE" == "true" ]]; then
            log_info "使用缓存的 symlink 文件列表"
        fi
    fi

    files_to_link=$(cat "$CACHE_FILE")

    if [[ -z "$files_to_link" ]]; then
        log_warn "没有找到需要链接的文件"
        return
    fi

    while IFS= read -r src; do
        [[ -z "$src" ]] && continue
        local dst
        dst="$HOME/.$(basename "${src%.*}")"
        link_file "$src" "$dst"
    done <<< "$files_to_link"
}

#==============================================================================
# Zsh setup (mandatory)
#==============================================================================
setup_zsh() {
    log_info "配置 Zsh..."

    # Install zsh if not present
    if ! command -v zsh >/dev/null 2>&1; then
        log_info "安装 Zsh..."
        local platform
        platform=$(detect_platform)
        case "$platform" in
            Darwin) brew install zsh ;;
            Linux)  sudo apt update && sudo apt install -y zsh ;;
            Cygwin) pact install zsh ;;
        esac
    fi

    # Change default shell to zsh
    if [[ "$SHELL" != *"zsh" ]]; then
        log_info "设置默认 shell 为 Zsh..."
        if [[ "$AUTO_MODE" == "true" ]]; then
            chsh -s "$(command -v zsh)"
        else
            read -p "是否将 Zsh 设为默认 shell? [Y/n] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                log_info "跳过设置默认 shell"
            else
                chsh -s "$(command -v zsh)"
            fi
        fi
    fi

    log_success "Zsh 配置完成"
}

#==============================================================================
# Tmux setup (mandatory)
#==============================================================================
setup_tmux() {
    log_info "配置 Tmux..."

    # Install tmux if not present
    if ! command -v tmux >/dev/null 2>&1; then
        log_info "安装 Tmux..."
        local platform
        platform=$(detect_platform)
        case "$platform" in
            Darwin) brew install tmux ;;
            Linux)  sudo apt install -y tmux ;;
            Cygwin) pact install tmux ;;
        esac
    fi

    # Install Tmux Plugin Manager
    if [[ ! -d "$TMUX_PLUGIN_DIR" ]]; then
        mkdir -p "$TMUX_PLUGIN_DIR"
        retry_command "git clone https://github.com/tmux-plugins/tpm '$TMUX_PLUGIN_DIR'"
    else
        retry_command "cd '$TMUX_PLUGIN_DIR' && git pull --rebase origin master"
    fi
    tmux source "$HOME/.tmux.conf" 2>/dev/null || true
    log_success "Tmux 配置完成"
}

#==============================================================================
# Banner and system info
#==============================================================================
show_banner() {
    echo ""
    echo -e "\033[1;37m╔══════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;37m║                    Dotfiles Installer                       ║\033[0m"
    echo -e "\033[1;37m║              Cross-Platform Setup Tool                      ║\033[0m"
    echo -e "\033[1;37m╚══════════════════════════════════════════════════════════════╝\033[0m"
    echo ""
}

show_system_info() {
    if [[ -f "$DOTFILES_ROOT/scripts/common/utils.sh" ]]; then
        source "$DOTFILES_ROOT/scripts/common/utils.sh"
        
        echo -e "\033[1;37m=== 系统信息 ===\033[0m"
        log_info "平台: $(detect_platform)"
        
        if [[ "$(detect_platform)" == "linux" ]]; then
            log_info "发行版: $(detect_linux_distro)"
        fi
        
        log_info "Shell: $(detect_shell)"
        log_info "包管理器: $(detect_package_manager)"
        echo ""
    fi
}

#==============================================================================
# Package installation (optional)
#==============================================================================
install_packages() {
    local platform
    platform=$(detect_platform)
    local install_script=""

    case "$platform" in
        Darwin) install_script="$DOTFILES_ROOT/platforms/mac/install.sh" ;;
        Linux)  install_script="$DOTFILES_ROOT/platforms/linux/install.sh" ;;
        Cygwin)
            log_warn "Cygwin 平台暂无包安装脚本"
            return 0
            ;;
    esac

    if [[ ! -f "$install_script" ]]; then
        log_warn "未找到包安装脚本: $install_script"
        return 0
    fi

    log_info "运行平台包安装脚本..."
    
    if [[ "$AUTO_MODE" == "true" ]]; then
        bash "$install_script" --auto
    else
        bash "$install_script"
    fi
}

#==============================================================================
# Environment template (optional)
#==============================================================================
apply_environment_template() {
    local env="$1"
    local template_script="$DOTFILES_ROOT/templates/template-manager.sh"

    if [[ ! -f "$template_script" ]]; then
        log_warn "未找到模板管理器: $template_script"
        return 0
    fi

    log_info "应用开发环境模板: $env"
    bash "$template_script" apply "$env"
}

#==============================================================================
# Health check
#==============================================================================
run_health_check() {
    local health_script="$DOTFILES_ROOT/scripts/health/health-check.sh"

    if [[ ! -f "$health_script" ]]; then
        log_warn "未找到健康检查脚本: $health_script"
        return 0
    fi

    log_info "运行系统健康检查..."
    bash "$health_script" | tail -20
}

#==============================================================================
# Installation summary
#==============================================================================
show_summary() {
    echo ""
    echo -e "\033[0;32m╔══════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[0;32m║                    安装完成!                                ║\033[0m"
    echo -e "\033[0;32m╚══════════════════════════════════════════════════════════════╝\033[0m"
    echo ""
    echo "下一步:"
    echo "  1. 重启终端或运行: source ~/.zshrc"
    echo "  2. 运行健康检查: $DOTFILES_ROOT/scripts/health/health-check.sh"
    echo "  3. 查看状态: $DOTFILES_ROOT/scripts/dotfile-manager.sh status"
    echo ""
}

#==============================================================================
# Main
#==============================================================================
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            --auto)
                AUTO_MODE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --with-packages)
                WITH_PACKAGES=true
                shift
                ;;
            --env)
                if [[ -z "${2:-}" ]]; then
                    log_error "--env 需要指定环境名称"
                    exit 1
                fi
                ENVIRONMENT="$2"
                shift 2
                ;;
            --skip-health)
                SKIP_HEALTH=true
                shift
                ;;
            --skip-update)
                SKIP_UPDATE=true
                shift
                ;;
            *)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Show banner
    show_banner

    # Phase 1: Self-contained stage
    log_info "Phase 1: 前置检查..."
    check_prerequisites

    local platform
    platform=$(detect_platform)
    if [[ "$VERBOSE" == "true" ]]; then
        log_info "检测到平台: $platform"
    fi

    log_info "Phase 1: 仓库管理..."
    clone_or_update

    mkdir -p "$LOGS_DIR"

    log_info "Phase 1: 创建配置文件链接..."
    install_dotfiles "$platform"

    log_info "Phase 1: 配置 Zsh..."
    setup_zsh

    log_info "Phase 1: 配置 Tmux..."
    setup_tmux

    # Phase 2: Enhancement stage
    log_info "Phase 2: 加载增强功能..."
    show_system_info

    # Phase 3: Optional components
    if [[ "$WITH_PACKAGES" == "true" ]]; then
        log_info "Phase 3: 安装系统包..."
        install_packages
    fi

    if [[ -n "$ENVIRONMENT" ]]; then
        log_info "Phase 3: 应用环境模板..."
        apply_environment_template "$ENVIRONMENT"
    fi

    # Phase 4: Validation
    if [[ "$SKIP_HEALTH" != "true" ]]; then
        log_info "Phase 4: 健康检查..."
        run_health_check
    fi

    # Summary
    show_summary
}

main "$@"
