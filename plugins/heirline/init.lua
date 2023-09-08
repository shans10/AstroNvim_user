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
      opts.winbar = require "user.plugins.heirline.winbar"
    elseif not vim.g.winbar_enabled then
      opts.winbar = nil
    end

    -- return the final configuration table
    return opts
  end,
}
