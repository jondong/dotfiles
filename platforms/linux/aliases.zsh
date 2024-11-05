#==============================================================================
# Linux 平台 Alias 配置
#==============================================================================
local dist=$(lsb_release -is)
if [[ "$dist" == "Ubuntu" ]]; then
  alias cat='batcat'
  alias fd='fdfind'
elif [[ "$dist" == "openSUSE" ]]; then
  alias cat='bat'
fi