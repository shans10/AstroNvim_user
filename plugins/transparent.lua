return {
  "xiyaowong/transparent.nvim",
  lazy = false,
  cond = not vim.g.neovide,
  opts = {
    groups = {
      "Normal",
      "NormalNC",
      "Comment",
      "Constant",
      "Special",
      "Identifier",
      "Statement",
      "PreProc",
      "Type",
      "Underlined",
      "Todo",
      "String",
      "Function",
      "Conditional",
      "Repeat",
      "Operator",
      "Structure",
      "LineNr",
      "NonText",
      "SignColumn",
      "CursorLineNr",
      "EndOfBuffer",
    },
    extra_groups = {
      "FloatBorder",
      "NeoTreeNormal",
      "NeoTreeNormalNC",
      "NeoTreeTabActive",
      "NormalFloat",
      -- "StatusLine",
      "WhichKeyFloat",
    },
  },
  keys = {
    { "<leader>uT", "<cmd>TransparentToggle<CR>", desc = "Toggle transparency" },
  },
}
