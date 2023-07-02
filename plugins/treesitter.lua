return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    { "andymass/vim-matchup",    init = function() vim.g.matchup_matchparen_deferred = 1 end },
    { "HiPhish/nvim-ts-rainbow2" },
  },
  opts = {
    highlight = { disable = { "help" } },
    matchup = { enable = true },
    rainbow = { enable = true },
  },
}
