local status = require "astronvim.utils.status"

-- An `init` function to build a set of children components for LSP breadcrumbs
local function breadcrumbs_init(opts)
  opts = require("astronvim.utils").extend_tbl({
    max_depth = 5,
    separator = status.env.separators.breadcrumbs or "  ",
    icon = { enabled = true, hl = status.env.icon_highlights.breadcrumbs },
    padding = { left = 0, right = 0 },
  }, opts)
  return function(self)
    local data = require("aerial").get_location(true) or {}
    local children = {}
    -- add prefix if needed, use the separator if true, or use the provided character
    if opts.prefix and not vim.tbl_isempty(data) then
      table.insert(children, { provider = opts.prefix == true and opts.separator or opts.prefix })
    end
    local start_idx = 0
    if opts.max_depth and opts.max_depth > 0 then
      start_idx = #data - opts.max_depth
      if start_idx > 0 then
        table.insert(children, { provider = require("astronvim.utils").get_icon "Ellipsis" .. opts.separator })
      end
    end
    -- create a child for each level
    for i, d in ipairs(data) do
      if i > start_idx then
        local child = {
          { provider = string.gsub(d.name, "%%", "%%%%"):gsub("%s*->%s*", "") }, -- add symbol name
          on_click = { -- add on click function
            minwid = status.utils.encode_pos(d.lnum, d.col, self.winnr),
            callback = function(_, minwid)
              local lnum, col, winnr = status.utils.decode_pos(minwid)
              vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { lnum, col })
            end,
            name = "heirline_breadcrumbs",
          },
        }
        if opts.icon.enabled then -- add icon and highlight if enabled
          local hl = opts.icon.hl
          if type(hl) == "function" then hl = hl(self) end
          local hlgroup = string.format("Aerial%sIcon", d.kind)
          table.insert(child, 1, {
            provider = string.format("%s ", d.icon),
            hl = (hl and vim.fn.hlexists(hlgroup) == 1) and hlgroup or nil,
          })
        end
        table.insert(child, 1, { provider = opts.separator }) -- add a separator before element
        table.insert(children, child)
      end
    end
    if opts.padding.left > 0 then -- add left padding
      table.insert(children, 1, { provider = status.utils.pad_string(" ", { left = opts.padding.left - 1 }) })
    end
    if opts.padding.right > 0 then -- add right padding
      table.insert(children, { provider = status.utils.pad_string(" ", { right = opts.padding.right - 1 }) })
    end
    -- instantiate the new child
    self[1] = self:new(children, 1)
  end
end

return {
  -- default highlight for the entire winbar
  hl = { fg = "winbar_fg" },
  init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
  -- add a component to show filename
  status.component.file_info {
    file_icon = { hl = status.hl.file_icon "winbar" },
    file_modified = { str = "[+]", icon = "" },
    file_read_only = { str = "[-]", icon = "" },
    hl = status.hl.get_attributes("winbar", true),
    surround = false,
    unique_path = {},
  },
  -- add a component to show breadcrumbs
  status.component.builder {
    condition = function() return status.condition.is_active() and vim.g.breadcrumbs end,
    init = breadcrumbs_init()
  }
}
