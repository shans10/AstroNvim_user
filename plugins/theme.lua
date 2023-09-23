return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      transparent_background = true,
      dim_inactive = { enabled = true, percentage = 0.35 },
      integrations = {
        aerial = true,
        dap = { enabled = true, enable_ui = true },
        mason = true,
        neotree = true,
        notify = true,
        nvimtree = false,
        sandwich = true,
        semantic_tokens = true,
        symbols_outline = true,
        telescope = true,
        treesitter = true,
        which_key = true,
      },
    }
  },
  {
    "shaunsingh/nord.nvim",
    dependencies = {
      "xiyaowong/transparent.nvim",
      event = "UIEnter",
      opts = {
        groups = {
          'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
          'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
          'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
          'SignColumn', 'CursorLineNr', 'EndOfBuffer', 'WhichKeyFloat', 'NormalFloat',
          'FloatBorder'
        },
      },
    },
    config = function()
      vim.g.nord_contrast = true
      vim.g.nord_borders = true
      vim.g.nord_disable_background = true
      vim.g.nord_uniform_diff_background = true

      -- Disable semantic highlights
      vim.highlight.priorities.semantic_tokens = 95
    end,
  }
}
