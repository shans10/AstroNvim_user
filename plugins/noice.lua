local utils = require "astronvim.utils"

return {
  "folke/noice.nvim",
  event = "VeryLazy",
  -- cond = not vim.g.neovide,
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = function(_, opts)
    return utils.extend_tbl(opts, {
      cmdline = { view = "cmdline" },
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = utils.is_available "inc-rename.nvim", -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
      routes = {
        { filter = { event = "msg_show", find = "^/", ["not"] = { kind = "search_count" } }, opts = { skip = true } }, -- skip searched text message
      },
      views = {
        split = {
          enter = true,
          size = "50%",
        },
      }
    })
  end,
  init = function()
    vim.g.lsp_handlers_enabled = false

    --- Scroll hover documentation
    --
    -- Scroll forwards
    vim.keymap.set({"n", "i", "s"}, "<c-f>", function()
      if not require("noice.lsp").scroll(4) then
        return "<c-f>"
      end
    end, { silent = true, expr = true })

    -- Scroll backwards
    vim.keymap.set({"n", "i", "s"}, "<c-b>", function()
      if not require("noice.lsp").scroll(-4) then
        return "<c-b>"
      end
    end, { silent = true, expr = true })
  end,
}
