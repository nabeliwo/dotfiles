local M = {}

M.config = {
  window_background_opacity = 0.85,
  macos_window_background_blur = 10,
  window_decorations = "RESIZE",

  hide_tab_bar_if_only_one_tab = true,
  show_new_tab_button_in_tab_bar = false,
  show_close_tab_button_in_tabs = false,

  window_frame = {
    inactive_titlebar_bg = "none",
    active_titlebar_bg = "none",
  },

  window_background_gradient = {
    colors = { "#000000" },
  },

  colors = {
    tab_bar = {
      inactive_tab_edge = "none",
    },
  }
}

M.setup = function(wezterm, config)
  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local background = "#5c6d74"
    local foreground = "#FFFFFF"

    if tab.is_active then
      background = "#1285de"
      foreground = "#FFFFFF"
    end

    local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

    return {
      { Background = { Color = background } },
      { Foreground = { Color = foreground } },
      { Text = title },
    }
  end)
end

return M