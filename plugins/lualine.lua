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
      lualine_b = { "branch", "diff" },
      lualine_c = {
        {
          "filename",
          newfile_status = true,
          -- path = 4,
        },
        -- "searchcount"
      },
      lualine_x = {
        "diagnostics",
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
      lualine_y = { "progress" },
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
