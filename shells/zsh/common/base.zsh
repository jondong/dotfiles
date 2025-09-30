#==============================================================================
# 基础配置 - Common Base Configuration
#==============================================================================

# Prevent system zshrc from making keyboard changes that might cause zle errors
export DEBIAN_PREVENT_KEYBOARD_CHANGES=1

# Ensure proper shell options for job control and line editor
setopt monitor 2>/dev/null || true
setopt zle 2>/dev/null || true

# Enable Powerlevel10k instant prompt only if zle is available
if [[ -n "${ZLE_VERSION-}" ]] && [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable profiling (uncomment to debug startup time)
# zmodload zsh/zprof

#==============================================================================
# Zinit Plugin Manager Setup
#==============================================================================

# Check if Zinit is installed, install if not
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

# Load Zinit
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load only essential Oh My Zsh components
zinit snippet OMZ::lib/completion.zsh
zinit snippet OMZ::lib/history.zsh
zinit snippet OMZ::lib/key-bindings.zsh
zinit snippet OMZ::lib/theme-and-appearance.zsh

# Essential bundles (light-weight loading)
zinit light-mode for \
    zsh-users/zsh-completions \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-syntax-highlighting \
    paulirish/git-open

# Powerlevel10k theme
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Load Oh My Zsh plugins properly
zinit snippet OMZ::plugins/command-not-found/command-not-found.plugin.zsh
zinit snippet OMZ::plugins/git/git.plugin.zsh