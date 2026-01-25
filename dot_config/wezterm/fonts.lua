local wezterm = require 'wezterm'

local M = {}

M.config = {
  font = wezterm.font_with_fallback({
    { family = "Hack Nerd Font", scale = 1.0 },
    { family = "Noto Sans Mono CJK JP", scale = 1.0 },
  }),

  line_height = 1.05,
  font_size = 13.0,

  -- 日本語 + Nerd Font 混在時におすすめ
  harfbuzz_features = {
    "calt=1",
    "liga=1",
    "clig=1",
  },
}

M.setup = function(wezterm, config)
  -- あれば書く
end

return M
