#!/bin/bash

# Platform detection utilities
# Provides consistent platform detection across all scripts

# Platform detection
detect_platform() {
    case "$(uname -s)" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Linux distribution detection
detect_linux_distro() {
    if [[ ! -f /etc/os-release ]]; then
        echo "unknown"
        return
    fi

    . /etc/os-release
    echo "$ID"
}

# Desktop environment detection
detect_desktop_env() {
    if [[ -n "${XDG_CURRENT_DESKTOP:-}" ]]; then
        echo "$XDG_CURRENT_DESKTOP"
        return
    fi

    # Fallback methods
    if [[ -n "${DESKTOP_SESSION:-}" ]]; then
        echo "$DESKTOP_SESSION"
        return
    fi

    # Try to detect based on running processes
    if pgrep -x "gnome-shell" > /dev/null; then
        echo "gnome"
    elif pgrep -x "plasmashell" > /dev/null; then
        echo "kde"
    elif pgrep -x "xfce4-session" > /dev/null; then
        echo "xfce"
    elif pgrep -x "i3" > /dev/null; then
        echo "i3"
    else
        echo "unknown"
    fi
}

# Shell detection
detect_shell() {
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        echo "zsh"
    elif [[ -n "${BASH_VERSION:-}" ]]; then
        echo "bash"
    elif [[ -n "${FISH_VERSION:-}" ]]; then
        echo "fish"
    else
        echo "${SHELL:-unknown}"
    fi
}

# Package manager detection
detect_package_manager() {
    local platform=$(detect_platform)

    case "$platform" in
        "macos")
            if command -v brew > /dev/null; then
                echo "homebrew"
            else
                echo "none"
            fi
            ;;
        "linux")
            local distro=$(detect_linux_distro)
            case "$distro" in
                ubuntu|debian)
                    if command -v apt > /dev/null; then
                        echo "apt"
                    fi
                    ;;
                centos|rhel|fedora)
                    if command -v yum > /dev/null; then
                        echo "yum"
                    elif command -v dnf > /dev/null; then
                        echo "dnf"
                    fi
                    ;;
                arch)
                    if command -v pacman > /dev/null; then
                        echo "pacman"
                    fi
                    ;;
                *)
                    echo "unknown"
                    ;;
            esac
            ;;
        "windows")
            if command -v choco > /dev/null; then
                echo "chocolatey"
            else
                echo "none"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Hardware detection
detect_cpu_info() {
    local platform=$(detect_platform)

    case "$platform" in
        "macos")
            sysctl -n machdep.cpu.brand_string
            ;;
        "linux")
            if [[ -f /proc/cpuinfo ]]; then
                grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs
            else
                echo "unknown"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

detect_memory_info() {
    local platform=$(detect_platform)

    case "$platform" in
        "macos")
            local mem_bytes=$(sysctl -n hw.memsize)
            echo $((mem_bytes / 1024 / 1024 / 1024))GB
            ;;
        "linux")
            if [[ -f /proc/meminfo ]]; then
                local mem_kb=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
                echo $((mem_kb / 1024 / 1024))GB
            else
                echo "unknown"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Network detection
detect_network_env() {
    # Check for common corporate/proxy indicators
    if [[ -n "${http_proxy:-}" ]] || [[ -n "${HTTPS_PROXY:-}" ]]; then
        echo "proxy"
    elif ping -c 1 -W 1 8.8.8.8 > /dev/null 2>&1; then
        echo "direct"
    else
        echo "restricted"
    fi
}

# System info summary
get_system_info() {
    cat << EOF
System Information:
- Platform: $(detect_platform)
- Linux Distribution: $(detect_linux_distro)
- Desktop Environment: $(detect_desktop_env)
- Shell: $(detect_shell)
- Package Manager: $(detect_package_manager)
- CPU: $(detect_cpu_info)
- Memory: $(detect_memory_info)
- Network Environment: $(detect_network_env)
EOF
}

# Platform-specific commands
get_platform_commands() {
    local platform=$(detect_platform)

    case "$platform" in
        "macos")
            echo "brew open defaults pbcopy pbpaste"
            ;;
        "linux")
            local distro=$(detect_linux_distro)
            case "$distro" in
                ubuntu|debian)
                    echo "apt apt-get dpkg"
                    ;;
                centos|rhel|fedora)
                    echo "yum dnf rpm"
                    ;;
                arch)
                    echo "pacman"
                    ;;
            esac
            ;;
        "windows")
            echo "choco powershell cmd"
            ;;
    esac
}

# Export functions if sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f detect_platform detect_linux_distro detect_desktop_env
    export -f detect_shell detect_package_manager
    export -f detect_cpu_info detect_memory_info detect_network_env
    export -f get_system_info get_platform_commands
fi