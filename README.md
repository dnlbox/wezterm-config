# wezterm-config

WezTerm, Starship, Zsh, and a portable VS Code profile for macOS.

## Quick Installation

Clone your copy of this repository or extract a snapshot to a directory of your choice. Run the installer from that directory.

```bash
./install.sh
exec zsh
```

The installer safely backs up pre-existing configs before symlinking, clones necessary Zsh plugins, and sets up a private `~/.zshrc.local` template for sensitive API credentials.

Keep the checkout in place after installing. The symlinks point to its resolved location. Zsh discovers Homebrew from the receiving Mac and respects `XDG_CONFIG_HOME` for Starship. Put optional paths for machine-specific tools such as Antigravity in the receiving machine's `~/.zshrc.local`.

## Import the VS Code profile

1. For matching editor and terminal fonts on macOS, run `brew install --cask font-monaspice-nerd-font font-meslo-lg-nerd-font`.
2. In VS Code, open **Profiles** from the Manage menu. Open the **New Profile** dropdown, choose **Import Profile**, and select [`vscode/portable.code-profile`](vscode/portable.code-profile).
3. Review the settings, keyboard shortcuts, UI state, and extensions, then choose **Create**. Use **Use for New Windows** on the imported profile to make it the default for new windows.

Importing from a local file works without Settings Sync. VS Code installs compatible extensions from the Marketplace subject to availability and company policy. Sign in to any required services with the company account.

The profile preserves macOS shortcuts. It uses the project's TypeScript SDK under `node_modules` when available, and the Markdown Preview Enhanced PlantUML JAR path can be set locally if needed. Window dimensions and per-workspace editor state stay on each machine. The existing `Ctrl+P Ctrl+P` binding references a Multi Command macro that was absent from the source configuration.

## Prerequisites (macOS)

Install WezTerm, recommended Nerd Fonts, and companion CLI utilities via Homebrew:

```bash
# Terminal and typography
brew install --cask wezterm
brew install --cask font-monaspice-nerd-font font-symbols-only-nerd-font

# Prompt and shell utilities
brew install starship eza fzf zoxide fnm bat jq
```

## Security and Private Credentials

Keep private API keys, tokens, passwords, SSH material, client-specific URLs, and account state out of version control and profile exports. The checked-in profile holds editor preferences, keyboard shortcuts, selected layout settings, and public extension identifiers. Review profile diffs before replacing it with a new export.

The configuration sources `~/.zshrc.local` if it exists. Place all sensitive credentials (such as `AI_GATEWAY_API_KEY`, `OPENROUTER_API_KEY`, `ELEVENLABS_API_KEY`, or `PULUMI_CONFIG_PASSPHRASE`) into this file:

```bash
# Generated automatically by install.sh if missing
chmod 600 ~/.zshrc.local
```

Refer to `.zshrc.local.example` for reference templates.

## Features and Highlights

- **Visuals and Theme:** Matching Gruvbox dark pale palette across WezTerm and Starship prompt.
- **Typography:** Monaspice Neon Nerd Font with Radon italic companion and full HarfBuzz stylistic sets (`ss01` through `ss09`, texture healing, and ligatures).
- **Window Appearance:** Frosted glass background blur (opacity 0.85, blur radius 40) and 120 FPS maximum frame rate toggle for ProMotion displays.
- **Split Visibility:** Inactive split panes automatically shift to monochrome grayscale to keep active focus visually distinct.
- **Shell Colours and Highlighting:** Fast real-time command syntax colourisation and fish-like autosuggestions.
- **Modern Directory Navigation:** Integrated with `zoxide` (smart directory jumping with frecency) and `fzf` (fuzzy finding).
- **Modern Aliases:** `eza` replacements for `ls` (`l`, `ll`, `lt`), Git history summaries (`gtoday`, `gyesterday`, `gweek`), and quick navigation shortcuts.
- **AI Git Commits:** `gcmai` helper function using local Ollama models to generate conventional commit messages following strict style rules.

## WezTerm Key Bindings

| Key Combination | Action |
| :--- | :--- |
| `CMD + D` | Split pane horizontally |
| `CMD + Shift + D` | Split pane vertically |
| `CMD + W` | Close current pane (without prompt) |
| `CMD + K` | Clear scrollback and viewport |
| `CTRL + U` | Scroll up half page |
| `CTRL + D` | Scroll down half page |
| `CMD + O` | Open VS Code in current directory (`code .`) |
| `CMD + Shift + E` | Prompt to rename current tab |
| `CMD + [` / `CMD + ]` | Navigate to previous / next split pane |
| `CTRL + [` / `CTRL + ]` | Navigate to previous / next split pane |

## Zsh Key Bindings and Navigation

| Key Combination | Action |
| :--- | :--- |
| `Ctrl + B` | Fuzzy search command history (`fzf`) |
| `Ctrl + R` | Interactive folder selector (`zoxide zi`) |
| `Ctrl + H` | Jump directly to home directory (`z ~`) |
| `zh` | Alias to jump home (`z ~`) |
| `..` to `......` | Navigate up multiple directory levels |
| `-` | Switch to previous working directory (`cd -`) |
