#!/bin/bash

# Logging utilities for dotfiles scripts
# Provides consistent logging across all scripts

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Logging levels
readonly DEBUG=0
readonly INFO=1
readonly WARN=2
readonly ERROR=3
readonly FATAL=4

# Global log level (can be overridden by environment)
LOG_LEVEL=${LOG_LEVEL:-$INFO}

# Logging functions
log_debug() {
    if [[ $LOG_LEVEL -le $DEBUG ]]; then
        echo -e "${PURPLE}[DEBUG]${NC} $1" >&2
    fi
}

log_info() {
    if [[ $LOG_LEVEL -le $INFO ]]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    if [[ $LOG_LEVEL -le $WARN ]]; then
        echo -e "${YELLOW}[WARN]${NC} $1" >&2
    fi
}

log_error() {
    if [[ $LOG_LEVEL -le $ERROR ]]; then
        echo -e "${RED}[ERROR]${NC} $1" >&2
    fi
}

log_fatal() {
    if [[ $LOG_LEVEL -le $FATAL ]]; then
        echo -e "${RED}[FATAL]${NC} $1" >&2
    fi
}

# Progress indicator
progress_start() {
    echo -n "${CYAN}$1${NC}..."
}

progress_end() {
    echo -e " ${GREEN}✓${NC}"
}

# Section headers
section() {
    echo -e "\n${WHITE}=== $1 ===${NC}"
}

subsection() {
    echo -e "\n${CYAN}--- $1 ---${NC}"
}

# Status indicators
status_ok() {
    echo -e "${GREEN}✓${NC} $1"
}

status_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

status_error() {
    echo -e "${RED}✗${NC} $1"
}

status_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Summary table
print_summary() {
    local ok=$1
    local warn=$2
    local error=$3
    local total=$((ok + warn + error))

    echo -e "\n${WHITE}=== Health Check Summary ===${NC}"
    echo -e "Total checks: $total"
    echo -e "${GREEN}Passed: $ok${NC}"
    echo -e "${YELLOW}Warnings: $warn${NC}"
    echo -e "${RED}Errors: $error${NC}"

    if [[ $error -eq 0 ]]; then
        if [[ $warn -eq 0 ]]; then
            echo -e "\n${GREEN}🎉 All checks passed!${NC}"
        else
            echo -e "\n${YELLOW}⚠ Some warnings detected, but system is functional${NC}"
        fi
        return 0
    else
        echo -e "\n${RED}❌ Critical issues found! Please address errors.${NC}"
        return 1
    fi
}

# Export functions if sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f log_debug log_info log_success log_warn log_error log_fatal
    export -f progress_start progress_end
    export -f section subsection
    export -f status_ok status_warn status_error status_info
    export -f print_summary
fi