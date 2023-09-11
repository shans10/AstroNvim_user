return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    -- List of supported themes to match with currently selected theme
    local themes = { ["doom"] = true,["lunarvim"] = true,["nvchad"] = true, ["simple"] = true }

    -- Get current statusline theme, set it to "astronvim" if it is nil
    local theme = vim.g.heirline_theme

    -- Override statusline configuration
    -- Set statusline based on chosen theme
    if themes[theme] then
      opts.statusline = require("user.plugins.heirline.themes." .. theme)
    end

    -- Override winbar configuration
    if (theme == "lunarvim" or theme == nil) and vim.o.stal == 0 then
      local status = require "astronvim.utils.status"
      opts.winbar[2] = {
        status.component.file_info { -- add file_info to breadcrumbs
          file_icon = { hl = status.hl.filetype_color, padding = { left = 1 } },
          file_modified = { str = "[+]", icon = "" },
          file_read_only = { str = "[-]", icon = "" },
          hl = status.hl.get_attributes("winbar", true),
          surround = false,
        },
        status.component.breadcrumbs {
          condition = function() return status.condition.aerial_available() and vim.g.breadcrumbs end,
          icon = { hl = true },
          hl = status.hl.get_attributes("winbar", true),
          prefix = true,
          padding = { left = 0 },
        },
      }
    elseif not vim.g.winbar_enabled then
      opts.winbar = nil
    end

    -- return the final configuration table
    return opts
  end,
}
