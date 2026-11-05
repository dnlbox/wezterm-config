# wezterm-config

Personal WezTerm terminal configuration tailored for macOS, featuring a Gruvbox dark palette, Monaspace font ligatures, frosted glass blur, smooth 120 FPS rendering, and keyboard-centric pane navigation.

## Quick Installation

Run the following commands on a new computer to clone and link the configuration:

```bash
git clone https://github.com/dnlbox/wezterm-config.git ~/.config/wezterm
~/.config/wezterm/install.sh
```

Alternatively, if you prefer cloning into your projects or dotfiles folder (such as `~/forge/wezterm-config`):

```bash
git clone https://github.com/dnlbox/wezterm-config.git ~/forge/wezterm-config
cd ~/forge/wezterm-config
./install.sh
```

The installer safely backs up any existing `~/.wezterm.lua` or `~/.config/wezterm/wezterm.lua` file before creating symlinks.

## Prerequisites (macOS)

Install WezTerm and the recommended Monaspace Nerd Font using Homebrew:

```bash
brew install --cask wezterm
brew install --cask font-monaspice-nerd-font font-symbols-only-nerd-font
```

## Features and Highlights

- **Visuals and Theme:** Gruvbox dark pale (base16) colour scheme with custom tab bar styling.
- **Typography:** Monaspice Neon Nerd Font with Radon italic companion and full HarfBuzz stylistic sets (`ss01` through `ss09`, texture healing, and ligatures).
- **Smooth Scrolling:** 120 FPS maximum frame rate toggle for ProMotion displays.
- **Window Appearance:** Frosted glass background blur (opacity 0.85, blur radius 40).
- **Smart Tabs:** Tab titles automatically display the current working folder and active foreground process, filtering out standard shell names.
- **Split Visibility:** Inactive split panes automatically shift to monochrome grayscale to keep active focus visually distinct.

## Key Bindings

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

## Customisation Toggles

Near the top of [`wezterm.lua`](wezterm.lua), several boolean flags allow rapid toggling:

```lua
local ENABLE_120_FPS = true           -- 120Hz animations and scrolling
local ENABLE_FROSTED_GLASS = true     -- macOS frosted glass blur and transparency
local ENABLE_GRAYSCALE_SPLITS = true  -- Turn inactive split panes monochrome
local ENABLE_INTEGRATED_BUTTONS = false -- Show macOS window buttons in tab bar
```
