return {
  "hrsh7th/cmp-cmdline",
  opts = function()
    local cmp_mapping = require "cmp.config.mapping"
    local cmp_sources = require "cmp.config.sources"

    return {
      mapping = cmp_mapping.preset.cmdline({
        ['<C-j>'] = {
          c = function(fallback)
            local cmp = require('cmp')
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end,
        },
        ['<C-k>'] = {
          c = function(fallback)
            local cmp = require('cmp')
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end,
        },
      }),
      sources = cmp_sources({
        { name = "path" },
      }, {
          {
            name = "cmdline",
            option = {
              ignore_cmds = { "Man", "!" },
            },
          },
        }, {
          { name = "buffer" },
        }),
    }
  end,
  config = function(_, opts) require("cmp").setup.cmdline(":", opts) end,
  dependencies = { "nvim-cmp" },
  event = { "CmdlineEnter" },
}
