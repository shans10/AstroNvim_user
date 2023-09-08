return {
  n = {
    ["<leader>ld"] = false, -- disable hover diagnostic keymap
    ["<leader>lD"] = false, -- change description in mappings
    ["<leader>ll"] = { function() vim.diagnostic.open_float() end, desc = "Line diagnostics" },
    ["gh"] = { function() vim.lsp.buf.hover() end, desc = "Hover symbol details" }
  }
}
