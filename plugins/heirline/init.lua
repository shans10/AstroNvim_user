return {
  "rebelot/heirline.nvim",
  optional = true,
  opts = function(_, opts)
    local is_available = require "astronvim.utils".is_available

    -- List of supported themes to match with currently selected theme
    local themes = { ["doom"] = true,["lunarvim"] = true, ["minimal"] = true,["nvchad"] = true }

    -- Get current statusline theme, set it to "astronvim" if it is nil
    local theme = vim.g.heirline_theme

    -- Override statusline configuration
    -- Disable statusline when lualine is installed
    if is_available "lualine.nvim" then
      opts.statusline = nil
    -- Set statusline based on chosen theme
    elseif themes[theme] then
      opts.statusline = require("user.plugins.heirline.themes." .. theme)
    end

    -- Override winbar configuration
    if (theme == nil or not themes[theme]) and vim.o.stal == 0 and not is_available "lualine.nvim" then
      local status = require "astronvim.utils.status"
      opts.winbar[2] = {
        -- show the path to the file relative to the working directory
        status.component.separated_path {
          condition = function() return not vim.g.breadcrumbs end,
          path_func = status.provider.filename { modify = ":.:h" }
        },
        -- add a component to show current filename
        status.component.file_info {
          file_icon = { hl = status.hl.filetype_color, padding = { left = 0 } },
          file_modified = { str = "[+]", icon = "" },
          file_read_only = { str = "[-]", icon = "" },
          -- unique_path = {},
          hl = status.hl.get_attributes("winbar", true),
          surround = false,
        },
        -- add a component to show lsp breadcrumbs
        status.component.breadcrumbs {
          condition = function() return status.condition.aerial_available() and vim.g.breadcrumbs end,
          icon = { hl = true },
          hl = status.hl.get_attributes("winbar", true),
          prefix = true,
          padding = { left = 0 },
        },
        -- fill the rest of the winbar
        -- the elements after this will appear in the right corner of the statusline
        -- status.component.fill(),
        -- status.component.builder {
        --   condition = function()
        --     return vim.fn.mode():find("[Vv]") ~= nil
        --   end,
        --   provider = function()
        --     local starts = vim.fn.line("v")
        --     local ends = vim.fn.line(".")
        --     local count = starts <= ends and ends - starts + 1 or starts - ends + 1
        --     return count .. "L "
        --   end,
        --   surround = { separator = "none" }
        -- },
        -- add a component to show relative path of current file
        -- status.component.builder {
        --   condition = function() return not vim.g.breadcrumbs end,
        --   hl = status.hl.get_attributes("winbarnc"),
        --   provider = function()
        --     local relative_path = vim.fn.expand("%:~:.:h")
        --     return status.utils.stylize(relative_path ~= "." and "[" .. relative_path .. "]")
        --   end,
        --   surround = { separator = "right" },
        -- },
      }
    elseif not vim.g.winbar_enabled then
      opts.winbar = nil
    end

    -- return the final configuration table
    return opts
  end,
}
