local wezterm = require 'wezterm'

local M = {}

M.setup = function(wezterm, config)
  -- Windows 環境の場合、デフォルトで WSL を起動
  -- WSL のデフォルトディストリビューションが使用されます
  if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
    config.default_prog = { 'wsl.exe', '~' }
  end
end

return M
