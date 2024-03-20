return {
  "rebelot/heirline.nvim",
  optional = true,
  opts = function(_, opts)
    local is_available = require("astronvim.utils").is_available

    -- List of supported themes to match with currently selected theme
    local themes = { ["doom"] = true, ["lunarvim"] = true, ["minimal"] = true, ["nvchad"] = true }

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
          path_func = status.provider.filename { modify = ":.:h" },
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
        -- add a buffer close button when breadcrumbs are inactive
        status.component.builder {
          condition = function() return not vim.g.breadcrumbs end,
          hl = { fg = "diag_ERROR" },
          provider = status.utils.pad_string(require("astronvim.utils").get_icon "BufferClose", { left = 1 }),
          padding = { left = 1 },
          on_click = {
            callback = function(_, minwid) require("astronvim.utils.buffer").close(minwid) end,
            minwid = function(self) return self.bufnr end,
            name = "heirline_tabline_close_buffer_callback",
          },
        },
      }
    elseif not vim.g.winbar_enabled then
      opts.winbar = nil
    end

    -- return the final configuration table
    return opts
  end,
}
