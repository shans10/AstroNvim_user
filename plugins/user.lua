return {
  { "simrat39/rust-tools.nvim" },
  {
    "lambdalisue/suda.vim",
    event = "User AstroFile",
    enabled = function() return not vim.g.win32 end
  },
}
