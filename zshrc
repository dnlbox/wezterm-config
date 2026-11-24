# Discover Homebrew from PATH or its standard macOS locations.
if ! command -v brew >/dev/null 2>&1 && [[ "$OSTYPE" == darwin* ]]; then
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$brew_bin" ]] || continue
    eval "$("$brew_bin" shellenv zsh)"
    break
  done
  unset brew_bin
fi

android_sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
tool_paths=()
for bin_dir in "$HOME/.cargo/bin" "${FLUTTER_ROOT:-$HOME/.flutter/flutter}/bin" \
  "$android_sdk/emulator" "$android_sdk/platform-tools" "$HOME/.local/bin"; do
  [[ -d "$bin_dir" ]] && tool_paths+=("$bin_dir")
done
path=("${tool_paths[@]}" "${path[@]}")
unset android_sdk bin_dir tool_paths

if command -v brew >/dev/null 2>&1; then
  brew_prefix="$(brew --prefix)"
  [[ -d "$brew_prefix/opt/python/libexec/bin" ]] && path=("$brew_prefix/opt/python/libexec/bin" "${path[@]}")
  [[ -d "$brew_prefix/opt/libpq/bin" ]] && path=("$brew_prefix/opt/libpq/bin" "${path[@]}")
  unset brew_prefix
fi

# JAVA
if [[ -x /usr/libexec/java_home ]]; then
  JAVA_HOME_PATH="$(/usr/libexec/java_home 2>/dev/null || true)"
  if [[ -n "${JAVA_HOME_PATH}" ]]; then
    export JAVA_HOME="${JAVA_HOME_PATH}"
    export CPPFLAGS="-I${JAVA_HOME}/include${CPPFLAGS:+ ${CPPFLAGS}}"
  fi
fi

# Node version manager (fnm: drop-in NVM replacement, ~40x faster startup)
# Migrate versions once: fnm install <version> for each node version you used
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY

# Completions
autoload -Uz compinit
compinit

# Bun completions (skip if broken)
[ -f "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Aliases
alias sol="solana"
alias solkgen="solana-keygen"
alias python="python3.13"
alias py="python3.11"
alias gdts="git diff-tree --no-commit-id --name-status -r"
alias gtoday='git --no-pager log --since="$(date '\''+%Y-%m-%d 00:00:00'\'')" \
  --pretty=format:"%C(yellow)%h%C(reset) %C(green)%ad%C(reset) %C(blue)%an%C(reset)%n%B%n---" \
  --date=short'

alias gyesterday='git --no-pager log \
  --since="$(date -v-1d '\''+%Y-%m-%d 00:00:00'\'')" \
  --until="$(date '\''+%Y-%m-%d 00:00:00'\'')" \
  --pretty=format:"%C(yellow)%h%C(reset) %C(green)%ad%C(reset) %C(blue)%an%C(reset)%n%B%n---" \
  --date=short'

alias gweek='git --no-pager log \
  --since="$(date -v-7d '\''+%Y-%m-%d 00:00:00'\'')" \
  --pretty=format:"%C(yellow)%h%C(reset) %C(green)%ad%C(reset) %C(blue)%an%C(reset)%n%B%n---" \
  --date=short'

alias ls='eza --icons --group-directories-first'
alias l='eza -la --icons --group-directories-first'
alias ll='eza -a --icons --group-directories-first'
alias lt='eza --tree --level=2 --all'

alias -- -='cd -'
alias ~='cd ~'
alias c='clear'
alias n='nvim'
alias cpwd="pwd | tr -d '\n' | pbcopy"
# alias ol='ollama'
# alias olp='ollama ps'
# alias oll='ollama list'
# alias ols='ollama stop'
# alias olr='ollama run'

# Dotdot navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# AI tooling
alias cl='claude --permission-mode auto'
alias cx='codex'
alias hd='herdr'
alias k='kilo'
alias oc='opencode'

# Local AI for simple queries
_q() {
  local prompt="$*"
  if [[ -z "$prompt" ]]; then
    echo "Usage: ? <prompt>"
    return 1
  fi

  local model="gemma-4-e2b-it-4bit"

  # Generate payload securely using jq
  local json_payload
  json_payload=$(jq -n \
    --arg model "$model" \
    --arg prompt "$prompt" \
    '{model: $model, messages: [{role: "user", content: $prompt}]}')

  # Query oMLX server and pipe to bat for clean markdown rendering
  curl -s -X POST http://127.0.0.1:8000/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d "$json_payload" | jq -r '.choices[0].message.content' | bat -l md --style=plain --paging=auto
}
alias '?'='noglob _q'
alias omlx-models="curl -s http://127.0.0.1:8000/v1/models | jq -r"

# Plugins
[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f ~/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ] && source ~/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
[ -f ~/.zsh/zsh-git-alias.zsh ] && source ~/.zsh/zsh-git-alias.zsh
[ -f ~/.zsh/gcmai.zsh ] && source ~/.zsh/gcmai.zsh

# fzf shell integration (Ctrl+R: fuzzy history, Ctrl+T: fuzzy files, Alt+C: fuzzy cd)
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
  bindkey '^b' fzf-history-widget
fi

# zoxide: smarter cd with frecency (z <query>, zi for interactive picker, zh for home)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  bindkey -s '^r' 'zi\n'
  bindkey -s '^h' 'z ~\n'
  alias zh='z ~'
fi

# Starship
export STARSHIP_CONFIG="${STARSHIP_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml}"
export STARSHIP_DISABLE_TELEMETRY=true

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# ZSH options
setopt autocd

# General settings
export DOTNET_CLI_TELEMETRY_OPTOUT=true

# This is so the error code doesn't cascade and close the terminal
# Not all terminals will close but some will and usually because applications
# like pulumi was crashing wezterm
# precmd() {
#   local exit_code=$?
#   if [[ $exit_code -ne 0 ]]; then
#     echo "[precmd hook] Last command exited with code: $exit_code"
#   fi
#   # Set the terminal tab title to the current folder name.
#   print -Pn "\e]0;%1~\a"
# }

# General utils
alias nuke_docker="docker stop \$(docker ps -aq) 2>/dev/null || true && docker rm \$(docker ps -aq) 2>/dev/null || true && docker rmi -f \$(docker images -q) 2>/dev/null || true && docker volume rm \$(docker volume ls -q) 2>/dev/null || true && docker network prune -f 2>/dev/null || true && docker system prune -a --volumes -f"

# pnpm
if [[ -z "${PNPM_HOME:-}" && "$OSTYPE" == darwin* && -d "$HOME/Library/pnpm" ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
fi
if [[ -n "${PNPM_HOME:-}" ]]; then
  [[ -d "$PNPM_HOME" && ":${PATH}:" != *":$PNPM_HOME:"* ]] && path=("$PNPM_HOME" "${path[@]}")
  [[ -d "$PNPM_HOME/bin" && ":${PATH}:" != *":$PNPM_HOME/bin:"* ]] && path=("$PNPM_HOME/bin" "${path[@]}")
fi

# Local environment variables and secrets (not committed to version control)
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
