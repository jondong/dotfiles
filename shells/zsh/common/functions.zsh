#==============================================================================
# 工具函数配置 - Utility Functions
#==============================================================================

lazy_load() {
    local cmd=$1
    local init_cmd=$2
    eval "function $cmd {
        unset -f $cmd
        eval '$init_cmd'
        $cmd \"\$@\"
    }"
}

setup_platform() {
	[[ -n "${PLATFORM:-}" ]] && return

	local platform_name
	platform_name="$(uname)"
	case "${platform_name}" in
		CYGWIN*)  export PLATFORM="Cygwin" ;;
		Darwin*)  export PLATFORM="Darwin" ;;
		Linux*)   export PLATFORM="Linux"  ;;
		*)        export PLATFORM="${platform_name:0:6}" ;;
	esac
}

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

directory_already_in_path() {
	local dir="${1}"
	[[ ":${PATH}:" == *":${dir}:"* ]]
}

_modify_path() {
	local dir="${1}"
	local position="${2:-append}"

	[[ ! -d "${dir}" ]] && return 1
	directory_already_in_path "${dir}" && return 0

	if [[ "${position}" == "prepend" ]]; then
		export PATH="${dir}:${PATH}"
	else
		export PATH="${PATH}:${dir}"
	fi
}

prepend_path_if_exists() {
	_modify_path "${1}" "prepend"
}

append_path_if_exists() {
	_modify_path "${1}" "append"
}
