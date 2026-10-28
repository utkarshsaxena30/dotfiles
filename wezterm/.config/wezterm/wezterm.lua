local wezterm = require('wezterm')
local act = wezterm.action
local mux = wezterm.mux

local config = wezterm.config_builder and wezterm.config_builder() or {}

-- ============================================================================
-- JSON Workspace Configuration Loader
-- ============================================================================
local WORKSPACES_JSON_PATH = wezterm.config_dir .. '/workspaces.json'
wezterm.add_to_config_reload_watch_list(WORKSPACES_JSON_PATH)

local function load_workspaces_config()
  local file, err = io.open(WORKSPACES_JSON_PATH, 'r')
  if not file then
    wezterm.log_error('Failed to open ' .. WORKSPACES_JSON_PATH .. ': ' .. tostring(err))
    return { settings = {}, copilot_sessions = {}, tabs = {} }
  end
  local content = file:read('*a')
  file:close()

  local ok, parsed = pcall(wezterm.json_parse, content)
  if not ok or type(parsed) ~= 'table' then
    wezterm.log_error('Failed to parse ' .. WORKSPACES_JSON_PATH .. ': ' .. tostring(parsed))
    return { settings = {}, copilot_sessions = {}, tabs = {} }
  end
  parsed.settings = parsed.settings or {}
  parsed.copilot_sessions = parsed.copilot_sessions or {}
  parsed.tabs = parsed.tabs or {}
  return parsed
end

local initial_ws = load_workspaces_config()
local wsl_distro = initial_ws.settings.wsl_distro or 'Ubuntu'
local wsl_home = initial_ws.settings.wsl_home or '/home/utsaxena'
local win_shell = initial_ws.settings.windows_shell or 'powershell.exe'
local color_scheme = initial_ws.settings.theme or 'Tokyo Night'

-- ============================================================================
-- Terminal & Visual Settings (matching your .tmux.conf theme & behavior)
-- ============================================================================
config.color_scheme = color_scheme
config.inactive_pane_hsb = {
  saturation = initial_ws.settings.inactive_pane_saturation or 0.65,
  brightness = initial_ws.settings.inactive_pane_brightness or 0.40,
}
config.default_prog = { win_shell, '-NoLogo' }
config.scrollback_lines = 5000
config.audible_bell = 'Disabled'
config.check_for_updates = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 32
config.window_decorations = 'TITLE | RESIZE'
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

config.wsl_domains = {
  {
    name = 'WSL:' .. wsl_distro,
    distribution = wsl_distro,
    default_cwd = wsl_home,
  },
}

config.colors = {
  split = '#eab308',
  tab_bar = {
    background = '#000000',
    active_tab = {
      bg_color = '#ef4444',
      fg_color = '#000000',
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = '#000000',
      fg_color = '#ffffff',
    },
    inactive_tab_hover = {
      bg_color = '#27272a',
      fg_color = '#eab308',
    },
    new_tab = {
      bg_color = '#000000',
      fg_color = '#ef4444',
    },
  },
}

wezterm.on('update-right-status', function(window, _)
  local ws_name = window:active_workspace()
  local date = wezterm.strftime('%Y-%m-%d %H:%M ')
  window:set_right_status(wezterm.format({
    { Foreground = { Color = '#000000' } },
    { Background = { Color = '#eab308' } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = ' [' .. ws_name .. '] ' .. date },
  }))
end)

-- ============================================================================
-- Spawn Spec Builder (Windows PowerShell vs WSL Interactive Bash)
-- ============================================================================
local function expand_wsl_path(p, home_dir)
  if not p or p == '' then
    return home_dir
  end
  if p == '~' then
    return home_dir
  end
  if p:sub(1, 2) == '~/' then
    return home_dir .. p:sub(2)
  end
  return p
end

local function build_spawn_spec(pane_cfg, tab_cfg, ws_cfg)
  local settings = ws_cfg.settings or {}
  local distro = settings.wsl_distro or wsl_distro
  local home_dir = settings.wsl_home or wsl_home
  local ps_exe = settings.windows_shell or win_shell

  local pane_type = pane_cfg.type or 'shell'
  local os_target = pane_cfg.os or (tab_cfg and tab_cfg.os) or 'windows'
  local cwd = pane_cfg.cwd or (tab_cfg and tab_cfg.cwd)
  local session_name = nil
  local custom_cmd = pane_cfg.cmd

  if pane_type == 'copilot' then
    local session_key = pane_cfg.session
    local session_entry = session_key and ws_cfg.copilot_sessions[session_key]
    if session_entry then
      os_target = pane_cfg.os or session_entry.os or os_target
      cwd = pane_cfg.cwd or session_entry.cwd or cwd
      session_name = session_entry.name or session_key
    else
      session_name = session_key
    end
  end

  if os_target == 'wsl' then
    local wsl_cwd = expand_wsl_path(cwd, home_dir)
    local inner_cmd
    if pane_type == 'nvim' then
      local target = pane_cfg.target or '.'
      inner_cmd = string.format('cd %q && nvim %s; exec bash -i', wsl_cwd, target)
    elseif pane_type == 'copilot' then
      if session_name and session_name ~= '' then
        inner_cmd = string.format('cd %q && copilot --resume=%q; exec bash -i', wsl_cwd, session_name)
      else
        inner_cmd = string.format('cd %q && copilot --continue; exec bash -i', wsl_cwd)
      end
    elseif pane_type == 'command' and custom_cmd then
      inner_cmd = string.format('cd %q && %s; exec bash -i', wsl_cwd, custom_cmd)
    else
      inner_cmd = string.format('cd %q && exec bash -i', wsl_cwd)
    end

    return {
      domain = { DomainName = 'local' },
      args = { 'wsl.exe', '-d', distro, '--cd', wsl_cwd, '--', 'bash', '-lic', inner_cmd },
    }
  else
    local win_cwd = cwd or wezterm.home_dir
    local args = { ps_exe, '-NoLogo' }

    if pane_type == 'nvim' then
      local target = pane_cfg.target or '.'
      args = { ps_exe, '-NoLogo', '-NoExit', '-Command', string.format('Set-Location -LiteralPath %q; nvim %s', win_cwd, target) }
    elseif pane_type == 'copilot' then
      if session_name and session_name ~= '' then
        args = { ps_exe, '-NoLogo', '-NoExit', '-Command', string.format('Set-Location -LiteralPath %q; copilot --resume=%s', win_cwd, session_name) }
      else
        args = { ps_exe, '-NoLogo', '-NoExit', '-Command', string.format('Set-Location -LiteralPath %q; copilot --continue', win_cwd) }
      end
    elseif pane_type == 'command' and custom_cmd then
      args = { ps_exe, '-NoLogo', '-NoExit', '-Command', string.format('Set-Location -LiteralPath %q; %s', win_cwd, custom_cmd) }
    end

    return {
      domain = { DomainName = 'local' },
      cwd = win_cwd,
      args = args,
    }
  end
end

-- ============================================================================
-- Startup Layout Builder (Driven by workspaces.json)
-- ============================================================================
local function populate_tab_panes(tab, first_pane, tab_cfg, ws_cfg)
  if tab_cfg.title then
    tab:set_title(tab_cfg.title)
  end

  local panes = { first_pane }
  local pane_configs = tab_cfg.panes or {}

  for i = 2, #pane_configs do
    local p_cfg = pane_configs[i]
    local target_idx = p_cfg.target_pane or (i - 1)
    local target_pane = panes[target_idx] or panes[#panes]
    local spec = build_spawn_spec(p_cfg, tab_cfg, ws_cfg)

    local direction = 'Right'
    if p_cfg.split then
      local s = string.lower(p_cfg.split)
      if s == 'bottom' or s == 'down' then
        direction = 'Bottom'
      elseif s == 'top' or s == 'up' then
        direction = 'Top'
      elseif s == 'left' then
        direction = 'Left'
      else
        direction = 'Right'
      end
    end

    spec.direction = direction
    spec.size = p_cfg.size or 0.5
    local new_pane = target_pane:split(spec)
    table.insert(panes, new_pane)
  end

  if first_pane then
    first_pane:activate()
  end
end

wezterm.on('gui-startup', function(cmd)
  -- Allow explicit `wezterm start -- <custom-cmd>` to bypass the workspace builder
  if cmd and cmd.args and #cmd.args > 0 then
    mux.spawn_window(cmd)
    return
  end

  local ws_cfg = load_workspaces_config()
  local tabs = ws_cfg.tabs or {}
  if #tabs == 0 then
    mux.spawn_window({})
    return
  end

  local layout_mode = (ws_cfg.settings and ws_cfg.settings.layout_mode) or 'single_window'
  local windows_by_group = {}
  local first_tabs_by_group = {}

  for _, tab_cfg in ipairs(tabs) do
    local group_key = (layout_mode == 'by_window_group') and (tab_cfg.window or 'default') or 'default'
    local first_pane_cfg = (tab_cfg.panes and tab_cfg.panes[1]) or { type = 'shell', os = tab_cfg.os, cwd = tab_cfg.cwd }
    local first_spec = build_spawn_spec(first_pane_cfg, tab_cfg, ws_cfg)

    if not windows_by_group[group_key] then
      local tab, pane, window = mux.spawn_window(first_spec)
      local gui_win = window:gui_window()
      if gui_win then
        gui_win:maximize()
      end
      windows_by_group[group_key] = window
      first_tabs_by_group[group_key] = tab
      populate_tab_panes(tab, pane, tab_cfg, ws_cfg)
    else
      local window = windows_by_group[group_key]
      local tab, pane = window:spawn_tab(first_spec)
      populate_tab_panes(tab, pane, tab_cfg, ws_cfg)
    end
  end

  for _, first_tab in pairs(first_tabs_by_group) do
    first_tab:activate()
  end
end)

-- ============================================================================
-- Dynamic Copilot Session Picker (Reads workspaces.json on every invocation)
-- ============================================================================
local function open_copilot_session_picker(open_mode)
  return wezterm.action_callback(function(window, pane)
    local ws_cfg = load_workspaces_config()
    local sessions = ws_cfg.copilot_sessions or {}

    local keys = {}
    for k, _ in pairs(sessions) do
      table.insert(keys, k)
    end
    table.sort(keys)

    local choices = {}
    for _, k in ipairs(keys) do
      local entry = sessions[k]
      local os_tag = string.upper(entry.os or 'windows')
      local desc = entry.description and (' — ' .. entry.description) or ''
      local cwd_str = entry.cwd and (' (' .. entry.cwd .. ')') or ''
      table.insert(choices, {
        id = k,
        label = string.format('[%s] %-24s%s%s', os_tag, k, desc, cwd_str),
      })
    end

    window:perform_action(
      act.InputSelector({
        title = 'Copilot Sessions (' .. open_mode .. ')',
        choices = choices,
        fuzzy = true,
        fuzzy_description = 'Pick a Copilot session from workspaces.json (' .. open_mode .. '): ',
        action = wezterm.action_callback(function(inner_window, inner_pane, id, _)
          if not id then
            return
          end
          local fresh_cfg = load_workspaces_config()
          local pane_cfg = { type = 'copilot', session = id }
          local spec = build_spawn_spec(pane_cfg, nil, fresh_cfg)

          if open_mode == 'tab' then
            local mux_win = inner_window:mux_window()
            local new_tab, _ = mux_win:spawn_tab(spec)
            new_tab:set_title(id)
          else
            spec.direction = 'Right'
            spec.size = 0.5
            inner_pane:split(spec)
          end
        end),
      }),
      pane
    )
  end)
end

-- ============================================================================
-- Zoomed pane pair: Ctrl-x m marks a pane, Ctrl-x ; toggles zoom between the
-- marked pane and the pane you toggled from. State lives in wezterm.GLOBAL
-- (per tab) so it survives config reloads.
-- ============================================================================
local function find_tab_pane(tab, pane_id)
  if not pane_id then
    return nil
  end
  for _, p in ipairs(tab:panes()) do
    if p:pane_id() == pane_id then
      return p
    end
  end
  return nil
end

local mark_zoom_pane = wezterm.action_callback(function(window, pane)
  local tab = pane:tab()
  if not tab then
    return
  end
  local id = tostring(tab:tab_id())
  wezterm.GLOBAL['zoom_mark_' .. id] = pane:pane_id()
  wezterm.GLOBAL['zoom_other_' .. id] = nil
  window:toast_notification('WezTerm', 'Pane marked for zoom toggle', nil, 1500)
end)

local toggle_zoom_pair = wezterm.action_callback(function(window, pane)
  local tab = pane:tab()
  if not tab then
    return
  end
  local id = tostring(tab:tab_id())
  local marked = find_tab_pane(tab, wezterm.GLOBAL['zoom_mark_' .. id])
  if not marked then
    window:toast_notification('WezTerm', 'No marked pane in this tab (Ctrl-x m)', nil, 2000)
    return
  end

  local target
  if pane:pane_id() == marked:pane_id() then
    target = find_tab_pane(tab, wezterm.GLOBAL['zoom_other_' .. id])
    if not target then
      window:toast_notification('WezTerm', 'Move to another pane, then Ctrl-x ;', nil, 2000)
      return
    end
  else
    wezterm.GLOBAL['zoom_other_' .. id] = pane:pane_id()
    target = marked
  end

  tab:set_zoomed(false)
  target:activate()
  tab:set_zoomed(true)
end)

-- ============================================================================
-- Keybindings (Matches your .tmux.conf: Ctrl-x prefix, | and - splits, etc.)
-- ============================================================================
config.leader = { key = 'x', mods = 'CTRL', timeout_milliseconds = 1500 }

config.keys = {
  -- Send literal Ctrl-a when pressing Leader + Ctrl-a (matches your .tmux.conf)
  { key = 'a', mods = 'LEADER|CTRL', action = act.SendKey({ key = 'a', mods = 'CTRL' }) },

  -- Split panes using | and - (CurrentPaneDomain keeps current OS/cwd)
  { key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
  { key = '\\', mods = 'LEADER', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
  { key = '-', mods = 'LEADER', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },

  -- Switch panes using Ctrl + Arrow without prefix (matches your .tmux.conf)
  { key = 'LeftArrow', mods = 'CTRL', action = act.ActivatePaneDirection('Left') },
  { key = 'RightArrow', mods = 'CTRL', action = act.ActivatePaneDirection('Right') },
  { key = 'UpArrow', mods = 'CTRL', action = act.ActivatePaneDirection('Up') },
  { key = 'DownArrow', mods = 'CTRL', action = act.ActivatePaneDirection('Down') },

  -- Zoom pane (Ctrl-x z) & close pane (Ctrl-x x)
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  -- Zoomed pair toggle: mark (Ctrl-x m), then flip between marked and current (Ctrl-x ;)
  { key = 'm', mods = 'LEADER', action = mark_zoom_pane },
  { key = ';', mods = 'LEADER', action = toggle_zoom_pair },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane({ confirm = true }) },

  -- Tabs (tmux windows): create (c), next (n), prev (p), rename (,)
  { key = 'c', mods = 'LEADER', action = act.SpawnTab('CurrentPaneDomain') },
  { key = 'u', mods = 'LEADER', action = act.SpawnCommandInNewTab({
    domain = { DomainName = 'local' },
    args = { 'wsl.exe', '-d', wsl_distro, '--cd', wsl_home },
  }) },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine({
      description = 'Rename current tab:',
      action = wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },

  -- Jump directly to tab 1..9 with Ctrl-x 1..9
  { key = '1', mods = 'LEADER', action = act.ActivateTab(0) },
  { key = '2', mods = 'LEADER', action = act.ActivateTab(1) },
  { key = '3', mods = 'LEADER', action = act.ActivateTab(2) },
  { key = '4', mods = 'LEADER', action = act.ActivateTab(3) },
  { key = '5', mods = 'LEADER', action = act.ActivateTab(4) },
  { key = '6', mods = 'LEADER', action = act.ActivateTab(5) },
  { key = '7', mods = 'LEADER', action = act.ActivateTab(6) },
  { key = '8', mods = 'LEADER', action = act.ActivateTab(7) },
  { key = '9', mods = 'LEADER', action = act.ActivateTab(8) },

  -- Reload configuration (Ctrl-x r)
  { key = 'r', mods = 'LEADER', action = act.ReloadConfiguration },

  -- Copy mode (Ctrl-x [)
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },

  -- Workspace launcher (Ctrl-x w)
  { key = 'w', mods = 'LEADER', action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES|TABS' }) },

  -- Copilot Session Picker from workspaces.json:
  --   Ctrl-x s -> open chosen session in a right split pane
  --   Ctrl-x S -> open chosen session in a new tab
  { key = 's', mods = 'LEADER', action = open_copilot_session_picker('split') },
  { key = 'S', mods = 'LEADER|SHIFT', action = open_copilot_session_picker('tab') },
}

return config
