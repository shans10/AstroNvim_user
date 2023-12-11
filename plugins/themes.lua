return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    enabled = false,
    opts = {
      flavour = "mocha",
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
    },
  },
  {
    "shaunsingh/nord.nvim",
    enabled = false,
    init = function()
      vim.g.nord_contrast = true
      vim.g.nord_borders = true
      vim.g.nord_uniform_diff_background = true
    end,
  },
  {
    "projekt0n/github-nvim-theme",
    -- enabled = false,
  },
  {
    "shans10/adwaita.nvim",
    enabled = false,
  },
}
