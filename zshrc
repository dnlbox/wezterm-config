# PATH setup
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.cargo/bin:$HOME/.flutter/flutter/bin:$HOME/Library/Android/sdk/emulator:$HOME/Library/Android/sdk/platform-tools:$HOME/.local/bin:$PATH"

# Override macOS's /usr/bin/python
export PATH="/opt/homebrew/opt/python/libexec/bin:$PATH"

# JAVA
export JAVA_HOME=$(/usr/libexec/java_home)
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

# Node version manager (fnm: drop-in NVM replacement, ~40x faster startup)
# Migrate versions once: fnm install <version> for each node version you used
eval "$(fnm env --use-on-cd --shell zsh)"

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
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source ~/.zsh/zsh-git-alias.zsh
source ~/.zsh/gcmai.zsh

# fzf shell integration (Ctrl+R: fuzzy history, Ctrl+T: fuzzy files, Alt+C: fuzzy cd)
source <(fzf --zsh)

# zoxide: smarter cd with frecency (z <query>, zi for interactive picker, zh for home)
eval "$(zoxide init zsh)"

# Keybinding swaps: Ctrl+B opens fzf history, Ctrl+R opens zoxide interactive folder switcher
bindkey '^b' fzf-history-widget
bindkey -s '^r' 'zi\n'

# Jump to home directory via Ctrl+H (or zh alias)
bindkey -s '^h' 'z ~\n'
alias zh='z ~'


# Starship
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
export STARSHIP_DISABLE_TELEMETRY=true

eval "$(starship init zsh)"

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
#   # Set terminal tab title to current folder name (e.g. "va-redirector", not full path)
#   print -Pn "\e]0;%1~\a"
# }

# General utils
alias nuke_docker="docker stop \$(docker ps -aq) 2>/dev/null || true && docker rm \$(docker ps -aq) 2>/dev/null || true && docker rmi -f \$(docker images -q) 2>/dev/null || true && docker volume rm \$(docker volume ls -q) 2>/dev/null || true && docker network prune -f 2>/dev/null || true && docker system prune -a --volumes -f"

# Postgress
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Added by Antigravity IDE
export PATH="$HOME/.antigravity-ide/antigravity-ide/bin:$PATH"

# Local environment variables and secrets (not committed to version control)
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
