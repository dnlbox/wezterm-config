local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- ============================================================================
-- 💡 COOL FEATURE TOGGLES (Easily toggle true/false to test or rollback!)
-- ============================================================================
local ENABLE_120_FPS = true           -- Butter-smooth 120Hz animations/scrolling
local ENABLE_FROSTED_GLASS = true     -- macOS frosted glass blur & transparency
local ENABLE_GRAYSCALE_SPLITS = true  -- Turn inactive split panes 100% monochrome
local ENABLE_INTEGRATED_BUTTONS = false -- Set true to show macOS traffic lights in tab bar
-- ============================================================================

-- UI and appearance
if ENABLE_120_FPS then
  config.max_fps = 120
end

if ENABLE_FROSTED_GLASS then
  config.window_background_opacity = 0.85
  config.macos_window_background_blur = 40
end

config.color_scheme = "Gruvbox dark, pale (base16)"
config.font = wezterm.font_with_fallback({
  { family = "MonaspiceNe Nerd Font Mono", weight = "Regular" },
  "Symbols Nerd Font Mono",
})
config.font_size = 16.0
config.line_height = 1.1 -- 1.0 is default; 1.1 gives a slight, comfortable increase in line spacing
-- Monaspace: texture healing (calt) + all code ligature sets (ss01 to ss09)
config.harfbuzz_features = {
  "calt=1", "clig=1", "liga=1",
  "ss01=1", "ss02=1", "ss03=1", "ss04=1", "ss05=1",
  "ss06=1", "ss07=1", "ss08=1", "ss09=1",
}
-- Use Radon (Monaspace's italic companion) for italic text
config.font_rules = {
  {
    italic = true,
    font = wezterm.font("MonaspiceRn Nerd Font Mono", { italic = true }),
  },
}
config.window_decorations = ENABLE_INTEGRATED_BUTTONS and "INTEGRATED_BUTTONS|RESIZE" or "RESIZE"

config.initial_rows = 50
config.initial_cols = 180
config.window_padding = {
  left = 16,
  right = 16,
  top = 16,
  bottom = 16,
}

-- Tab bar config
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 32

config.scrollback_lines = 10000
config.exit_behavior = "Hold"
config.clean_exit_codes = { 0, 130, 143, 255 }

config.colors = {
  tab_bar = {
    background = "#1d2021",
    active_tab = {
      bg_color = "#458588",
      fg_color = "#fbf1c7",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#3c3836",
      fg_color = "#a89984",
    },
    inactive_tab_hover = {
      bg_color = "#504945",
      fg_color = "#ebdbb2",
    },
    new_tab = {
      bg_color = "#1d2021",
      fg_color = "#bdae93",
    },
    new_tab_hover = {
      bg_color = "#504945",
      fg_color = "#ebdbb2",
      italic = true,
    },
  },
}

-- ============================================================================
-- Tab Title: Folder name + Process name disambiguation
-- ============================================================================
local SHELLS = {
  zsh = true,
  bash = true,
  fish = true,
  sh = true,
  nu = true,
  dash = true,
  ksh = true,
  login = true,
}

local function clean_process_name(process_path)
  if not process_path or #process_path == 0 then
    return ""
  end
  local name = process_path:match("([^/\\]+)$") or process_path
  name = name:gsub("^%-", "") -- strip login shell prefix (e.g. -zsh)
  return name:gsub("%.exe$", "")
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local tab_num = tab.tab_index + 1

  -- 1. Use manual custom tab title if set by user
  local title = tab.tab_title
  if not title or #title == 0 then
    local cwd = pane.current_working_dir
    local folder = ""
    if cwd then
      local path = (cwd.file_path or tostring(cwd)):gsub("/$", "")
      path = path:gsub("^" .. wezterm.home_dir, "~")
      folder = path:match("([^/]+)$") or path
    else
      folder = pane.title
    end

    local proc = clean_process_name(pane.foreground_process_name)
    if proc ~= "" and not SHELLS[proc] then
      title = string.format("%s [%s]", folder, proc)
    else
      title = folder
    end
  end

  local formatted = string.format(" %d: %s ", tab_num, title)
  return wezterm.truncate_right(formatted, max_width)
end)

-- Dim inactive panes so focus is visually obvious
if ENABLE_GRAYSCALE_SPLITS then
  config.inactive_pane_hsb = {
    saturation = 0.0,
    brightness = 0.5,
  }
else
  config.inactive_pane_hsb = {
    saturation = 0.8,
    brightness = 0.7,
  }
end

-- Key bindings
config.keys = {
  { key = "d", mods = "CMD",       action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "d", mods = "CMD|SHIFT", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = "w", mods = "CMD",       action = act.CloseCurrentPane { confirm = false } },
  { key = "k", mods = "CMD",       action = act.ClearScrollback "ScrollbackAndViewport" },
  { key = "u", mods = "CTRL",      action = act.ScrollByPage(-0.5) },
  { key = "d", mods = "CTRL",      action = act.ScrollByPage(0.5) },
  { key = "o", mods = "CMD",       action = act.SendString("code .\n") },
  {
    key = "e",
    mods = "CMD|SHIFT",
    action = act.PromptInputLine {
      description = "Rename current tab (leave empty to reset):",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  -- 🔁 The following switch to navigate between tabs
  -- { key = "[", mods = "CMD",       action = act.ActivateTabRelative(-1) },
  -- { key = "]", mods = "CMD",       action = act.ActivateTabRelative(1) },

  -- 🔁 Navigate between SPLITS (panes) in the current tab
  { key = "[", mods = "CMD",       action = act.ActivatePaneDirection "Prev" },
  { key = "]", mods = "CMD",       action = act.ActivatePaneDirection "Next" },
  { key = "[", mods = "CTRL",      action = act.ActivatePaneDirection "Prev" },
  { key = "]", mods = "CTRL",      action = act.ActivatePaneDirection "Next" },
}

return config
