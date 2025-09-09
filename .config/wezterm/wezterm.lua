local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- YAML-based workspace configuration loader
local function load_workspaces()
  local workspaces = {}
  local home = os.getenv('HOME')
  local config_path = home .. '/.config/wezterm/workspaces.yaml'
  
  -- Read YAML file
  local file = io.open(config_path, 'r')
  if not file then
    wezterm.log_error('Could not open workspaces.yaml: ' .. config_path)
    return {}
  end
  
  local content = file:read('*all')
  file:close()
  
  if not content or content == '' then
    wezterm.log_error('Empty or invalid workspaces.yaml file')
    return {}
  end
  
  -- Simple YAML-like parsing (basic approach for now)
  -- This is a simplified parser that works with our specific YAML structure
  local yaml_data = { workspaces = {} }
  local current_workspace = {}
  
  for line in content:gmatch("[^\r\n]+") do
    line = line:match("^%s*(.-)%s*$") -- trim whitespace
    if line:match("^%- id:") then
      if current_workspace.id then
        table.insert(yaml_data.workspaces, current_workspace)
      end
      current_workspace = { id = line:match("^%- id:%s*(.+)") }
    elseif line:match("^label:") then
      current_workspace.label = line:match('^label:%s*"?([^"]*)"?'):gsub('"', '')
    elseif line:match("^root:") then
      current_workspace.root = line:match('^root:%s*"?([^"]*)"?'):gsub('"', '')
    end
  end
  
  -- Add the last workspace
  if current_workspace.id then
    table.insert(yaml_data.workspaces, current_workspace)
  end
  
  if not yaml_data.workspaces then
    wezterm.log_error('No workspaces found in YAML file')
    return {}
  end
  
  -- Convert YAML data to workspace choices
  for _, workspace in ipairs(yaml_data.workspaces) do
    if workspace.id and workspace.label and workspace.root then
      -- Expand ~ to home directory
      local root_path = workspace.root:gsub('^~', home)
      table.insert(workspaces, {
        id = workspace.id,
        label = workspace.label,
        root = root_path
      })
    end
  end
  
  return workspaces
end


-- Window styling - hide title bar but keep resize borders
config.window_decorations = 'RESIZE'
config.window_background_opacity = 1.0

-- Theme and colors
config.color_scheme = 'Catppuccin Mocha'

-- Font configuration
config.font = wezterm.font('Rec Mono Duotone', { weight = 'Regular' })
config.font_size = 14.0

-- Tab bar configuration
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.show_tab_index_in_tab_bar = true

-- Shell configuration
config.default_prog = { '/opt/homebrew/bin/fish' }

-- Scrollback
config.scrollback_lines = 10000

-- Enable automatic configuration reload when workspaces.yaml changes
wezterm.add_to_config_reload_watch_list(os.getenv('HOME') .. '/.config/wezterm/workspaces.yaml')

-- Configure launcher appearance and behavior
config.launch_menu = {}
config.default_gui_startup_args = { 'start', '--' }

-- Mouse support
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.CompleteSelection('ClipboardAndPrimarySelection'),
  },
}

-- Window padding
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

-- Keybindings matching Zellij configuration
config.keys = {
  -- Tab management (matching Zellij shortcuts)
  { key = 't', mods = 'CMD', action = wezterm.action.SpawnTab 'CurrentPaneDomain' }, -- Super t
  { key = 'w', mods = 'CMD', action = wezterm.action.CloseCurrentTab { confirm = true } }, -- Super w
  { key = 'n', mods = 'ALT|SHIFT', action = wezterm.action.ActivateTabRelative(-1) }, -- Alt Shift n
  { key = 'm', mods = 'ALT|SHIFT', action = wezterm.action.ActivateTabRelative(1) }, -- Alt Shift m  
  { key = ',', mods = 'ALT|SHIFT', action = wezterm.action.MoveTabRelative(-1) }, -- Alt Shift ,
  { key = '.', mods = 'ALT|SHIFT', action = wezterm.action.MoveTabRelative(1) }, -- Alt Shift .

  -- Pane management (matching Zellij shortcuts)
  { key = 'u', mods = 'ALT|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } }, -- Alt Shift u (split down)
  { key = 'i', mods = 'ALT|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } }, -- Alt Shift i (split right)
  { key = 'h', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection 'Left' }, -- Alt Shift h
  { key = 'j', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection 'Down' }, -- Alt Shift j  
  { key = 'k', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection 'Up' }, -- Alt Shift k
  { key = 'l', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection 'Right' }, -- Alt Shift l
  { key = 'y', mods = 'ALT|SHIFT', action = wezterm.action.TogglePaneZoomState }, -- Alt Shift y (fullscreen)

  -- Workspace management (project switching - replaces Zellij windows)
  { key = 'w', mods = 'ALT|SHIFT', action = wezterm.action.ShowLauncher }, -- Alt Shift w (workspace launcher)
  { key = 'e', mods = 'ALT|SHIFT', action = wezterm.action.SpawnCommandInNewWindow { 
    args = { '/opt/homebrew/bin/nvim', os.getenv('HOME') .. '/.config/wezterm/workspaces.yaml' }
  } }, -- Alt Shift e (edit workspaces config)
  { key = 's', mods = 'ALT|SHIFT', action = wezterm.action.SwitchWorkspaceRelative(-1) }, -- Alt Shift s (previous workspace)
  { key = 'd', mods = 'ALT|SHIFT', action = wezterm.action.SwitchWorkspaceRelative(1) }, -- Alt Shift d (next workspace)

  -- System commands
  { key = 'q', mods = 'CMD', action = wezterm.action.QuitApplication }, -- Super q

  -- Standard macOS shortcuts
  { key = 'c', mods = 'CMD', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CMD', action = wezterm.action.PasteFrom 'Clipboard' },
  { key = 'k', mods = 'CMD', action = wezterm.action.ClearScrollback 'ScrollbackAndViewport' },

  -- Font size controls
  { key = '+', mods = 'CMD', action = wezterm.action.IncreaseFontSize },
  { key = '-', mods = 'CMD', action = wezterm.action.DecreaseFontSize },
  { key = '0', mods = 'CMD', action = wezterm.action.ResetFontSize },
  
  -- Claude Code integration - Shift+Enter for newlines
  { key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendString '\n' },
}

-- Format tab title to show workspace name
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local workspace_name = tab.active_pane.domain_name
  if workspace_name == 'local' then
    workspace_name = 'default'
  end
  
  local title = tab.tab_title
  if title and #title > 0 then
    title = title
  else
    title = tab.active_pane.title
  end
  
  -- Show workspace name in brackets for context
  return string.format('[%s] %d: %s', workspace_name, tab.tab_index + 1, title)
end)

-- Format window title to show current workspace
wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  local workspace_name = pane.domain_name
  if workspace_name == 'local' then
    workspace_name = 'default'
  end
  return string.format('%s - WezTerm', workspace_name)
end)

-- Augment the launcher with YAML workspace information
wezterm.on('augment-command-palette', function(window, pane)
  local mux = wezterm.mux
  local yaml_workspaces = load_workspaces()
  local palette = {}
  
  -- Get currently existing workspaces
  local success, existing_workspaces = pcall(mux.get_workspace_names, mux)
  if not success then
    existing_workspaces = {}
  end
  
  local success2, current_workspace = pcall(mux.get_active_workspace, mux)
  if not success2 then
    current_workspace = "default"
  end
  
  -- Add entries for YAML-defined workspaces that don't exist yet
  for _, workspace in ipairs(yaml_workspaces) do
    local already_exists = false
    for _, existing_name in ipairs(existing_workspaces) do
      if existing_name == workspace.id then
        already_exists = true
        break
      end
    end
    
    if not already_exists then
      local icon = " " -- folder icon for available workspaces
      -- Use special icons for specific workspace types
      if workspace.id == "dotfiles" then
        icon = " " -- home icon
      elseif workspace.root and workspace.root:match("Code/") then
        icon = " " -- code icon
      end
      
      table.insert(palette, {
        brief = icon .. workspace.label,
        icon = 'md_folder',
        action = wezterm.action_callback(function(window, pane)
          -- Create and switch to the workspace
          local success, tab, new_pane, new_window = pcall(mux.spawn_window, mux, {
            workspace = workspace.id,
            cwd = workspace.root,
          })
          if success and new_window then
            new_window:gui_window():set_title(workspace.label or workspace.id)
            pcall(mux.set_active_workspace, mux, workspace.id)
          end
        end),
      })
    end
  end
  
  return palette
end)

-- Pre-create workspaces from YAML configuration on startup
wezterm.on('gui-startup', function()
  local mux = wezterm.mux
  
  -- Load YAML workspaces and create them as available workspaces
  local yaml_workspaces = load_workspaces()
  
  -- Always create a default workspace first
  local default_tab, default_pane, default_window = mux.spawn_window {
    workspace = 'default',
  }
  
  -- Create workspaces from YAML configuration
  for _, workspace in ipairs(yaml_workspaces) do
    if workspace.id and workspace.root then
      -- Check if directory exists before creating workspace
      local f = io.open(workspace.root, 'r')
      if f then
        f:close()
        -- Create the workspace but don't switch to it yet
        local tab, pane, window = mux.spawn_window {
          workspace = workspace.id,
          cwd = workspace.root,
        }
        if window then
          window:gui_window():set_title(workspace.label or workspace.id)
        end
      else
        wezterm.log_info('Skipping workspace "' .. workspace.id .. '" - directory does not exist: ' .. workspace.root)
      end
    end
  end
  
  -- Set default workspace as active initially
  mux.set_active_workspace('default')
end)

return config
