#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SOURCE_CONFIG="${SCRIPT_DIR}/wezterm.lua"

CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/wezterm"
mkdir -p "${CONFIG_DIR}"
RESOLVED_CONFIG_DIR="$(cd "${CONFIG_DIR}" && pwd -P)"

CONFIG_FILE="${CONFIG_DIR}/wezterm.lua"
HOME_FILE="${HOME}/.wezterm.lua"

echo "==> Setting up WezTerm configuration..."

# Auto-recovery: if SOURCE_CONFIG was turned into a circular symlink from an earlier run
if [[ -L "${SOURCE_CONFIG}" ]]; then
  echo "Detected symlink at ${SOURCE_CONFIG}. Restoring original configuration..."
  rm -f "${SOURCE_CONFIG}"
  if [[ -d "${SCRIPT_DIR}/.git" ]]; then
    git -C "${SCRIPT_DIR}" checkout wezterm.lua 2>/dev/null || git -C "${SCRIPT_DIR}" restore wezterm.lua
  else
    LATEST_BACKUP="$(ls -t "${SCRIPT_DIR}"/wezterm.lua.backup.* 2>/dev/null | head -n 1 || true)"
    if [[ -n "${LATEST_BACKUP}" && -f "${LATEST_BACKUP}" ]]; then
      cp "${LATEST_BACKUP}" "${SOURCE_CONFIG}"
    fi
  fi
fi

if [[ ! -f "${SOURCE_CONFIG}" ]]; then
  echo "Error: Source configuration file not found at ${SOURCE_CONFIG}" >&2
  exit 1
fi

backup_if_needed() {
  local target="$1"
  local target_dir
  target_dir="$(cd "$(dirname "${target}")" 2>/dev/null && pwd -P || true)"
  local target_base
  target_base="$(basename "${target}")"
  local full_target="${target_dir}/${target_base}"

  if [[ -e "${target}" || -L "${target}" ]]; then
    # Do not back up if it already points directly to SOURCE_CONFIG
    if [[ -L "${target}" ]] && [[ "$(readlink "${target}" 2>/dev/null || true)" == "${SOURCE_CONFIG}" ]]; then
      return 0
    fi
    # Do not back up if it IS the source file
    if [[ "${full_target}" == "${SOURCE_CONFIG}" ]]; then
      return 0
    fi
    local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing ${target} -> ${backup}"
    mv "${target}" "${backup}"
  fi
}

# Scenario 1: Repository cloned directly into ~/.config/wezterm
if [[ "${SCRIPT_DIR}" == "${RESOLVED_CONFIG_DIR}" ]]; then
  echo "Repository is located directly in ~/.config/wezterm."
  echo "Configuration file is active at: ${CONFIG_FILE}"

  # Clean up any stale backup files in the repo directory
  rm -f "${SCRIPT_DIR}"/wezterm.lua.backup.*

  # Ensure ~/.wezterm.lua does not loop back or conflict
  if [[ -L "${HOME_FILE}" ]]; then
    target_link="$(readlink "${HOME_FILE}" 2>/dev/null || true)"
    if [[ "${target_link}" != "${CONFIG_FILE}" ]]; then
      rm -f "${HOME_FILE}"
      ln -sf "${CONFIG_FILE}" "${HOME_FILE}"
    fi
  elif [[ -f "${HOME_FILE}" ]]; then
    backup_if_needed "${HOME_FILE}"
    ln -sf "${CONFIG_FILE}" "${HOME_FILE}"
  else
    ln -sf "${CONFIG_FILE}" "${HOME_FILE}"
  fi
  echo "Symlinked:"
  echo "  ${HOME_FILE} -> ${CONFIG_FILE}"

# Scenario 2: Repository cloned into an external directory (e.g. ~/forge/wezterm-config)
else
  backup_if_needed "${CONFIG_FILE}"
  backup_if_needed "${HOME_FILE}"

  echo "Creating symlinks..."
  ln -sf "${SOURCE_CONFIG}" "${CONFIG_FILE}"
  ln -sf "${SOURCE_CONFIG}" "${HOME_FILE}"

  echo "Symlinked:"
  echo "  ${CONFIG_FILE} -> ${SOURCE_CONFIG}"
  echo "  ${HOME_FILE} -> ${SOURCE_CONFIG}"
fi

# Optional environment checks
if [[ "$(uname)" == "Darwin" ]]; then
  if command -v brew >/dev/null 2>&1; then
    if ! brew list --cask font-monaspice-nerd-font >/dev/null 2>&1; then
      echo ""
      echo "Note: Monaspice Nerd Font is recommended for full ligature and glyph support."
      echo "Install via Homebrew:"
      echo "  brew install --cask font-monaspice-nerd-font font-symbols-only-nerd-font"
    fi
  fi
fi

echo ""
echo "Setup complete! Restart WezTerm or press CMD+Shift+R to reload configuration."
