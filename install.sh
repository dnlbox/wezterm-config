#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_CONFIG="${SCRIPT_DIR}/wezterm.lua"

CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/wezterm"
CONFIG_FILE="${CONFIG_DIR}/wezterm.lua"
HOME_FILE="${HOME}/.wezterm.lua"

echo "==> Setting up WezTerm configuration..."

if [[ ! -f "${SOURCE_CONFIG}" ]]; then
  echo "Error: Source configuration file not found at ${SOURCE_CONFIG}" >&2
  exit 1
fi

mkdir -p "${CONFIG_DIR}"

backup_if_needed() {
  local target="$1"
  if [[ -e "${target}" || -L "${target}" ]]; then
    if [[ "$(readlink "${target}" 2>/dev/null || true)" == "${SOURCE_CONFIG}" ]]; then
      return 0
    fi
    local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing ${target} -> ${backup}"
    mv "${target}" "${backup}"
  fi
}

backup_if_needed "${CONFIG_FILE}"
backup_if_needed "${HOME_FILE}"

echo "Creating symlinks..."
ln -sf "${SOURCE_CONFIG}" "${CONFIG_FILE}"
ln -sf "${SOURCE_CONFIG}" "${HOME_FILE}"

echo "Symlinked:"
echo "  ${CONFIG_FILE} -> ${SOURCE_CONFIG}"
echo "  ${HOME_FILE} -> ${SOURCE_CONFIG}"

# Optional environment checks
if [[ "$(uname)" == "Darwin" ]]; then
  if command -v brew >/dev/null 2>&1; then
    if ! brew list --cask font-monaspice-nerd-font >/dev/null 2>&1; then
      echo ""
      echo "Note: Monaspice Nerd Font is recommended for full ligature and glyph support."
      echo "Install via Homebrew:"
      echo "  brew install --cask font-monaspice-nerd-font"
    fi
  fi
fi

echo ""
echo "Setup complete! Restart WezTerm or press CMD+Shift+R to reload configuration."
