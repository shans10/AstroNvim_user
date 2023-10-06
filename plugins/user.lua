return {
  { "simrat39/rust-tools.nvim" },
  {
    "ethanholz/nvim-lastplace",
    event = "User AstroFile",
    opts = {
      lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
      lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
      lastplace_open_folds = true,
    },
  },
  {
    "lambdalisue/suda.vim",
    cmd = {
      "SudaRead",
      "SudaWrite",
    },
    enabled = function() return not vim.g.win32 end,
  },
  {
    "echasnovski/mini.move",
    keys = {
      { "<A-h>", mode = { "n", "v" }, desc = "Move line/selection left" },
      { "<A-j>", mode = { "n", "v" }, desc = "Move line/selection down" },
      { "<A-k>", mode = { "n", "v" }, desc = "Move line/selection up" },
      { "<A-l>", mode = { "n", "v" }, desc = "Move line/selection right" },
    },
    opts = {},
  },
  {
    "arsham/indent-tools.nvim",
    dependencies = { "arsham/arshlib.nvim" },
    event = "User AstroFile",
    config = function() require("indent-tools").config {} end,
  },
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = {
      use_diagnostic_signs = true,
      action_keys = {
        close = { "q", "<esc>" },
        cancel = "<c-e>",
      },
    },
  },
  {
    "echasnovski/mini.surround",
    keys = {
      { "sa", desc = "Add surrounding", mode = { "n", "v" } },
      { "sd", desc = "Delete surrounding" },
      { "sf", desc = "Find right surrounding" },
      { "sF", desc = "Find left surrounding" },
      { "sh", desc = "Highlight surrounding" },
      { "sr", desc = "Replace surrounding" },
      { "sn", desc = "Update `MiniSurround.config.n_lines`" },
    },
    opts = { n_lines = 200 },
  },
  {
    "gbprod/cutlass.nvim",
    lazy = false,
    opts = { cut_key = "x" },
  },
}
