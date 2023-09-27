local is_available = require "astronvim.utils".is_available

-- Neovide settings
if vim.g.neovide then
  -- General
  vim.o.guifont = "JetBrainsMono Nerd Font:h11.5"
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_no_idle = true

  -- Cursor
  vim.g.neovide_cursor_animation_length = 0.03
  vim.g.neovide_cursor_trail_size = 0.1

  -- Transparency
  vim.g.neovide_transparency = 0.97

  -- Disable transparent.nvim plugin
  if is_available "transparent.nvim" then
    vim.cmd "TransparentDisable"
  end

  -- Clear highlight groups
  vim.cmd [[
    hi FloatBorder guibg=none
    hi NormalFloat guibg=none
    hi WhichKeyFloat guibg=none
  ]]
end

-- Load user autocmds
require "user.autocmds"
