#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SOURCE_WEZTERM="${SCRIPT_DIR}/wezterm.lua"
SOURCE_ZSHRC="${SCRIPT_DIR}/zshrc"
SOURCE_STARSHIP="${SCRIPT_DIR}/starship.toml"

CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}"
WEZTERM_CONFIG_DIR="${CONFIG_DIR}/wezterm"
mkdir -p "${WEZTERM_CONFIG_DIR}"
RESOLVED_WEZTERM_DIR="$(cd "${WEZTERM_CONFIG_DIR}" && pwd -P)"

WEZTERM_CONFIG_FILE="${WEZTERM_CONFIG_DIR}/wezterm.lua"
WEZTERM_HOME_FILE="${HOME}/.wezterm.lua"
ZSHRC_TARGET="${HOME}/.zshrc"
STARSHIP_TARGET="${CONFIG_DIR}/starship.toml"
ZSH_DIR="${HOME}/.zsh"
LOCAL_SECRETS="${HOME}/.zshrc.local"

echo "==> Setting up unified terminal environment (WezTerm + Zsh + Starship)..."

# Auto-recovery: if SOURCE_WEZTERM was turned into a circular symlink from an earlier run
if [[ -L "${SOURCE_WEZTERM}" ]]; then
  echo "Detected symlink at ${SOURCE_WEZTERM}. Restoring original configuration..."
  rm -f "${SOURCE_WEZTERM}"
  if [[ -d "${SCRIPT_DIR}/.git" ]]; then
    git -C "${SCRIPT_DIR}" checkout wezterm.lua 2>/dev/null || git -C "${SCRIPT_DIR}" restore wezterm.lua
  else
    LATEST_BACKUP="$(ls -t "${SCRIPT_DIR}"/wezterm.lua.backup.* 2>/dev/null | head -n 1 || true)"
    if [[ -n "${LATEST_BACKUP}" && -f "${LATEST_BACKUP}" ]]; then
      cp "${LATEST_BACKUP}" "${SOURCE_WEZTERM}"
    fi
  fi
fi

if [[ ! -f "${SOURCE_WEZTERM}" ]]; then
  echo "Error: Source configuration file not found at ${SOURCE_WEZTERM}" >&2
  exit 1
fi

backup_if_needed() {
  local target="$1"
  local source_file="$2"
  local target_dir
  target_dir="$(cd "$(dirname "${target}")" 2>/dev/null && pwd -P || true)"
  local target_base
  target_base="$(basename "${target}")"
  local full_target="${target_dir}/${target_base}"

  if [[ -e "${target}" || -L "${target}" ]]; then
    # Do not back up if it already points directly to source_file
    if [[ -L "${target}" ]] && [[ "$(readlink "${target}" 2>/dev/null || true)" == "${source_file}" ]]; then
      return 0
    fi
    # Do not back up if it IS the source file
    if [[ "${full_target}" == "${source_file}" ]]; then
      return 0
    fi
    local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing ${target} -> ${backup}"
    mv "${target}" "${backup}"
  fi
}

# --- 1. WezTerm Setup ---
echo ""
echo "--> Configuring WezTerm..."
if [[ "${SCRIPT_DIR}" == "${RESOLVED_WEZTERM_DIR}" ]]; then
  echo "Repository is located directly in ~/.config/wezterm."
  rm -f "${SCRIPT_DIR}"/wezterm.lua.backup.*

  if [[ -L "${WEZTERM_HOME_FILE}" ]]; then
    target_link="$(readlink "${WEZTERM_HOME_FILE}" 2>/dev/null || true)"
    if [[ "${target_link}" != "${WEZTERM_CONFIG_FILE}" ]]; then
      rm -f "${WEZTERM_HOME_FILE}"
      ln -sf "${WEZTERM_CONFIG_FILE}" "${WEZTERM_HOME_FILE}"
    fi
  elif [[ -f "${WEZTERM_HOME_FILE}" ]]; then
    backup_if_needed "${WEZTERM_HOME_FILE}" "${WEZTERM_CONFIG_FILE}"
    ln -sf "${WEZTERM_CONFIG_FILE}" "${WEZTERM_HOME_FILE}"
  else
    ln -sf "${WEZTERM_CONFIG_FILE}" "${WEZTERM_HOME_FILE}"
  fi
  echo "Symlinked: ${WEZTERM_HOME_FILE} -> ${WEZTERM_CONFIG_FILE}"
else
  backup_if_needed "${WEZTERM_CONFIG_FILE}" "${SOURCE_WEZTERM}"
  backup_if_needed "${WEZTERM_HOME_FILE}" "${SOURCE_WEZTERM}"
  ln -sf "${SOURCE_WEZTERM}" "${WEZTERM_CONFIG_FILE}"
  ln -sf "${SOURCE_WEZTERM}" "${WEZTERM_HOME_FILE}"
  echo "Symlinked:"
  echo "  ${WEZTERM_CONFIG_FILE} -> ${SOURCE_WEZTERM}"
  echo "  ${WEZTERM_HOME_FILE} -> ${SOURCE_WEZTERM}"
fi

# --- 2. Zsh & Starship Setup ---
echo ""
echo "--> Configuring Zsh & Starship prompt..."
mkdir -p "${CONFIG_DIR}"
mkdir -p "${ZSH_DIR}"

backup_if_needed "${ZSHRC_TARGET}" "${SOURCE_ZSHRC}"
ln -sf "${SOURCE_ZSHRC}" "${ZSHRC_TARGET}"
echo "Symlinked: ${ZSHRC_TARGET} -> ${SOURCE_ZSHRC}"

backup_if_needed "${STARSHIP_TARGET}" "${SOURCE_STARSHIP}"
ln -sf "${SOURCE_STARSHIP}" "${STARSHIP_TARGET}"
echo "Symlinked: ${STARSHIP_TARGET} -> ${SOURCE_STARSHIP}"

# Symlink custom Zsh scripts
backup_if_needed "${ZSH_DIR}/gcmai.zsh" "${SCRIPT_DIR}/zsh/gcmai.zsh"
ln -sf "${SCRIPT_DIR}/zsh/gcmai.zsh" "${ZSH_DIR}/gcmai.zsh"

backup_if_needed "${ZSH_DIR}/zsh-git-alias.zsh" "${SCRIPT_DIR}/zsh/zsh-git-alias.zsh"
ln -sf "${SCRIPT_DIR}/zsh/zsh-git-alias.zsh" "${ZSH_DIR}/zsh-git-alias.zsh"
echo "Symlinked custom Zsh modules into ${ZSH_DIR}"

# Install plugins
if [[ ! -d "${ZSH_DIR}/zsh-autosuggestions" ]]; then
  echo "Cloning zsh-autosuggestions..."
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_DIR}/zsh-autosuggestions"
fi

if [[ ! -d "${ZSH_DIR}/fast-syntax-highlighting" ]]; then
  echo "Cloning fast-syntax-highlighting..."
  git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting "${ZSH_DIR}/fast-syntax-highlighting"
fi

# Local secrets template
if [[ ! -f "${LOCAL_SECRETS}" ]]; then
  echo "Creating private secrets template at ${LOCAL_SECRETS}..."
  cp "${SCRIPT_DIR}/.zshrc.local.example" "${LOCAL_SECRETS}"
  chmod 600 "${LOCAL_SECRETS}"
  echo "Created: ${LOCAL_SECRETS} (permissions 600, safe for API keys)"
fi

# --- 3. Dependency Checks ---
if [[ "$(uname)" == "Darwin" ]]; then
  if command -v brew >/dev/null 2>&1; then
    MISSING_CASKS=()
    for cask in font-monaspice-nerd-font font-symbols-only-nerd-font; do
      if ! brew list --cask "${cask}" >/dev/null 2>&1; then
        MISSING_CASKS+=("${cask}")
      fi
    done

    MISSING_FORMULAE=()
    for formula in starship eza fzf zoxide fnm bat jq; do
      if ! brew list --formula "${formula}" >/dev/null 2>&1 && ! command -v "${formula}" >/dev/null 2>&1; then
        MISSING_FORMULAE+=("${formula}")
      fi
    done

    if [[ ${#MISSING_CASKS[@]} -gt 0 || ${#MISSING_FORMULAE[@]} -gt 0 ]]; then
      echo ""
      echo "Note: The following recommended packages are not yet installed via Homebrew:"
      [[ ${#MISSING_CASKS[@]} -gt 0 ]] && echo "  Casks:    brew install --cask ${MISSING_CASKS[*]}"
      [[ ${#MISSING_FORMULAE[@]} -gt 0 ]] && echo "  CLI tools: brew install ${MISSING_FORMULAE[*]}"
    fi
  fi
fi

echo ""
echo "Setup complete!"
echo "  - Restart WezTerm or press CMD+Shift+R to reload terminal styling."
echo "  - Run 'exec zsh' to activate all aliases and Starship prompt colours."
