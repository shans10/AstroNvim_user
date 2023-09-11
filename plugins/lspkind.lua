return {
  "onsails/lspkind.nvim",
  opts = function(_, opts)
    opts.mode = 'symbol_text'
    opts.menu = ({
      nvim_lsp = "[LSP]",
      luasnip = "[LuaSnip]",
      buffer = "[Buffer]",
      path = "[Path]",
    })
    opts.preset = 'codicons'
    opts.symbol_map = {
      Array = "",
      Boolean = "",
      Class = "",
      Color = "",
      Constant = "",
      Constructor = "",
      Enum = "",
      EnumMember = "",
      Event = "",
      Field = "",
      File = "",
      Folder = "",
      Function = "",
      Interface = "",
      Key = "",
      Keyword = "",
      Method = "",
      Module = "",
      Namespace = "",
      Null = "ﳠ",
      Number = "",
      Object = "",
      Operator = "",
      Package = "",
      Property = "",
      Reference = "",
      Snippet = "",
      String = "",
      Struct = "",
      Text = "",
      TypeParameter = "",
      Unit = "",
      Value = "",
      Variable = "",
    }
    return opts
  end
}
