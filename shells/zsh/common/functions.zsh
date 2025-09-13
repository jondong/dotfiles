#==============================================================================
# 工具函数配置 - Utility Functions
#==============================================================================

# Lazy loading for explain function
explain() {
    if ! command -v curl >/dev/null 2>&1; then
        echo "curl is required for explain function"
        return 1
    fi

	if [ "$#" -eq 0 ]; then
		while read -p "Command: " cmd; do
			[ -z "$cmd" ] && break
			curl -Gs "https://www.mankier.com/api/explain/?cols="$(tput cols) --data-urlencode "q=$cmd"
		done
		echo "Bye!"
	elif [ "$#" -eq 1 ]; then
		curl -Gs "https://www.mankier.com/api/explain/?cols="$(tput cols) --data-urlencode "q=$1"
	else
		echo "Usage"
		echo "explain                   interactive mode."
		echo "explain 'cmd -o | ...'    one quoted command to explain it."
	fi
}

# Proxy functions
set_proxy() {
	export http_proxy="$1"
	export https_proxy="$1"
}

set_npm_proxy() {
	export npm_config_proxy="$1"
	export npm_config_https_proxy="$1"
}

# Lazy loading functions for heavy tools
lazy_load() {
    local cmd=$1
    local init_cmd=$2
    eval "function $cmd {
        unset -f $cmd
        eval '$init_cmd'
        $cmd \"\$@\"
    }"
}

# Platform detection function
setup_platform() {
	# 如果 PLATFORM 已经设置，则跳过
	[[ -n "${PLATFORM:-}" ]] && return

	# 获取平台名称并规范化
	local platform_name
	platform_name="$(uname)"
	case "${platform_name}" in
		CYGWIN*)  export PLATFORM="Cygwin" ;;
		Darwin*)  export PLATFORM="Darwin" ;;
		Linux*)   export PLATFORM="Linux"  ;;
		*)        export PLATFORM="${platform_name:0:6}" ;;
	esac
}

# Check if command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Check if directory is already in PATH
directory_already_in_path() {
	local dir="${1}"
	[[ ":${PATH}:" == *":${dir}:"* ]]
}

# PATH management functions
_modify_path() {
	local dir="${1}"
	local position="${2:-append}"  # default to append

	# Validate directory
	[[ ! -d "${dir}" ]] && return 1
	directory_already_in_path "${dir}" && return 0

	# Add path based on position
	if [[ "${position}" == "prepend" ]]; then
		export PATH="${dir}:${PATH}"
	else
		export PATH="${PATH}:${dir}"
	fi
}

# Add directory to PATH prefix
prepend_path_if_exists() {
	_modify_path "${1}" "prepend"
}

# Add directory to PATH suffix
append_path_if_exists() {
	_modify_path "${1}" "append"
}