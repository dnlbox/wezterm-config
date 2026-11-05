# wezterm-config

Unified terminal and shell environment tailored for macOS, combining WezTerm, Starship prompt colours, Zsh aliases, and privacy-first credential management in a single repository.

## Quick Installation

Run the following commands on a new computer to clone and install the complete environment:

```bash
git clone https://github.com/dnlbox/wezterm-config.git ~/.config/wezterm
~/.config/wezterm/install.sh
exec zsh
```

Alternatively, if you prefer cloning into your projects or dotfiles directory (such as `~/forge/wezterm-config`):

```bash
git clone https://github.com/dnlbox/wezterm-config.git ~/forge/wezterm-config
cd ~/forge/wezterm-config
./install.sh
exec zsh
```

The installer safely backs up pre-existing configs before symlinking, clones necessary Zsh plugins, and sets up a private `~/.zshrc.local` template for sensitive API credentials.

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

Private API keys, tokens, and machine-specific passwords are never stored in version control.

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
