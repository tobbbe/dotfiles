local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font_size = 16.0
config.font = wezterm.font 'SFMono Nerd Font'
config.bold_brightens_ansi_colors = true
-- config.front_end = "WebGpu"
config.line_height = 1.4
-- config.freetype_load_flags = "NO_HINTING"
-- config.freetype_load_target = "HorizontalLcd" -- waves
-- config.freetype_render_target = "HorizontalLcd" -- waves

local tobbe_theme = wezterm.color.get_builtin_schemes()['Catppuccin Mocha']
tobbe_theme.background = '#0F0F19'
tobbe_theme.foreground = "#c7c7c7"
config.color_schemes = {
    ['tobbe'] = tobbe_theme,
}
config.color_scheme = 'tobbe'

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.93
-- config.kde_window_background_blur = true
config.macos_window_background_blur = 32
config.window_padding = {
    left = 8,
    right = 8,
    top = 8,
    bottom = 8,
}
config.window_frame = {
    font = wezterm.font { family = 'SFMono Nerd Font', weight = 'Bold' },
    font_size = 16.0,
    active_titlebar_bg = '#0F0F19',
    inactive_titlebar_bg = '#0F0F19',
}

config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true

config.colors = {
    cursor_bg = '#9DF1A1',
    tab_bar = {
        inactive_tab_edge = '#0F0F19',
        background = '#0F0F19',
        active_tab = {
            bg_color = '#0F0F19',
            fg_color = '#c0c0c0',
        },
        inactive_tab = {
            bg_color = '#0F0F19',
            fg_color = '#606060',
        },
    },
}

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local title = tab.active_pane.title
  
  if tab.is_active then
    return {
      { Text = ' ' .. title .. ' ' },
    }
  end
  
  return ' ' .. title .. ' '
end)


return config