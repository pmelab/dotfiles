local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Tabline plugin for enhanced tab bar
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

-- Smart workspace switcher plugin
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

-- Configure tabline plugin
tabline.setup({
	options = {
		icons_enabled = true,
		theme = "Catppuccin Mocha",
		color_overrides = {},
		section_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
		component_separators = {
			left = wezterm.nerdfonts.pl_left_soft_divider,
			right = wezterm.nerdfonts.pl_right_soft_divider,
		},
		tab_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
	},
	sections = {
		tab_active = {
			{ "tab", padding = 0 },
			":",
			{ "parent", padding = { left = 1, right = 0 } },
			"/",
			{ "cwd", padding = { left = 0, right = 1 } },
			"zoomed",
		},
		tab_inactive = {
			{ "tab", padding = 0 },
			"zoomed",
		},
	},
})

-- Apply tabline to config
tabline.apply_to_config(config)

-- Configure smart workspace switcher
workspace_switcher.zoxide_path = "/opt/homebrew/bin/zoxide"

-- Set up LEADER key for workspace switcher (plugin expects this)
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

-- Apply workspace switcher to config (this adds LEADER+s keybinding)
workspace_switcher.apply_to_config(config)

-- Theme and colors
config.color_scheme = "Catppuccin Mocha"

-- Font configuration
config.font = wezterm.font("Rec Mono Duotone", { weight = "Regular" })
config.font_size = 14.0

-- Window and pane padding
config.window_padding = {
	left = 16,
	right = 16,
	top = 16,
	bottom = 16,
}

-- Enable status bar for modal plugin UI
config.status_update_interval = 1000
config.use_fancy_tab_bar = false

-- Key bindings (Zellij-style)
config.keys = {
	-- Claude code shift+enter
	{ key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },

	-- === PANE MANAGEMENT (Zellij-style) ===
	-- New pane shortcuts

	-- Pane navigation (Alt+Shift + hjkl and arrow keys)
	{ key = "h", mods = "ALT|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "j", mods = "ALT|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "k", mods = "ALT|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "l", mods = "ALT|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },

	-- Maximize/toggle current pane
	{ key = "y", mods = "ALT|SHIFT", action = wezterm.action.TogglePaneZoomState },

	-- Additional pane splitting options
	{ key = "u", mods = "ALT|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "i", mods = "ALT|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

	-- === TAB MANAGEMENT (Zellij-style) ===
	-- New tab
	{ key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") },

	-- Tab navigation
	{ key = "n", mods = "ALT|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "m", mods = "ALT|SHIFT", action = wezterm.action.ActivateTabRelative(1) },
	{ key = ",", mods = "ALT|SHIFT", action = wezterm.action.MoveTabRelative(-1) },
	{ key = ".", mods = "ALT|SHIFT", action = wezterm.action.MoveTabRelative(1) },

	-- Close tab
	{ key = "w", mods = "CMD", action = wezterm.action.CloseCurrentTab({ confirm = true }) },

	-- Rename current tab
	{
		key = "t",
		mods = "ALT|SHIFT",
		action = wezterm.action.PromptInputLine({
			description = "Enter new tab title:",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- === SMART WORKSPACE SWITCHER ===
	-- Workspace/project switcher (leverages zoxide)
	-- Plugin adds LEADER+s by default, but we also add Alt+Shift+O
	{
		key = "o",
		mods = "ALT|SHIFT",
		action = workspace_switcher.switch_workspace(),
	},
}

return config
