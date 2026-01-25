local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.automatically_reload_config = true

local modules = {
  require 'appearance',
  require 'input',
  require 'fonts',
  require 'keybinds',
}

-- config をマージ
for _, m in ipairs(modules) do
  if m.config then
    for k, v in pairs(m.config) do
      config[k] = v
    end
  end
end

-- setup を実行
for _, m in ipairs(modules) do
  if m.setup then
    m.setup(wezterm, config)
  end
end

return config
