return {
  { "simrat39/rust-tools.nvim" },
  {
    "lambdalisue/suda.vim",
    event = "User AstroFile",
    enabled = function() return not vim.g.win32 end
  },
  {
    "echasnovski/mini.move",
    keys = {
      { "<M-l>", mode = { "n", "v" } },
      { "<M-k>", mode = { "n", "v" } },
      { "<M-j>", mode = { "n", "v" } },
      { "<M-h>", mode = { "n", "v" } },
    },
    opts = {},
  },
}
