return {
  "nvim-lualine/lualine.nvim",
  enabled = false,
  event = "VeryLazy",
  opts = {
    options = {
      icons_enabled = true,
      component_separators = { left = "|", right = "|" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = {
        statusline = { "alpha", "neo-tree" },
      },
      ignore_focus = { "toggleterm" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        {
          "branch",
          color = { fg = "fg" },
          separator = "",
        },
        "diff"
      },
      lualine_c = {
        {
          "filename",
          newfile_status = true,
          path = 4,
        },
        "diagnostics",
        -- "searchcount"
      },
      lualine_x = {
        {
          "fileformat",
          symbols = {
            unix = "unix",
            dos = "dos",
            mac = "mac",
          }
        },
        "filetype"
      },
      lualine_y = {
        {
          "progress",
          -- color = { fg = "fg" }
        }
      },
      lualine_z = { "location" }
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {}
    },
  }
}
