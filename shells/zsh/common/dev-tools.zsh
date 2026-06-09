#==============================================================================
# 开发工具配置 - Development Tools Configuration
#==============================================================================

[[ -r "$HOME/.openclaw/completions/openclaw.zsh" ]] && source "$HOME/.openclaw/completions/openclaw.zsh"

[[ -d "$HOME/.lmstudio/bin" ]] && export PATH="$PATH:$HOME/.lmstudio/bin"

[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"

[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

fpath=($HOME/.docker/completions $fpath)

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export HARMONY_HOME="$HOME/.local/share/harmony/command-line-tools"
export PATH="$HARMONY_HOME/bin:$PATH"

export ANDROID_HOME="$HOME/.local/share/android"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

if [[ -d "/usr/lib/jvm/java-17-openjdk-amd64" ]]; then
    export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
    export PATH="$JAVA_HOME/bin:$PATH"
elif [[ -n "${HOMEBREW_PREFIX:-}" ]] && [[ -d "$HOMEBREW_PREFIX/opt/openjdk" ]]; then
    export JAVA_HOME="$HOMEBREW_PREFIX/opt/openjdk"
    export PATH="$JAVA_HOME/bin:$PATH"
fi
