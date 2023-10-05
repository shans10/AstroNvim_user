local is_available = require "astronvim.utils".is_available
local status = require "astronvim.utils.status"

-- A highlight function to return highlight based on vi mode
local function mode_hl()
  local mode_fg = status.env.modes[vim.fn.mode()][2]
  return { fg = mode_fg, bg = "bg", bold = true }
end

-- A condition function if buffer is a valid file
local function is_valid_file_condition(self)
  local bufnr = self and self.bufnr or 0
  return not status.condition.buffer_matches ({
    buftype = { "nofile", "prompt", "quickfix" },
    filetype = { "^git.*", "fugitive", "toggleterm", "NvimTree" },
  }, bufnr)
end

-- A provider function to get current mode text
local function mode_text()
  return function()
    local text = status.env.modes[vim.fn.mode()][1]
    return status.utils.stylize("-- " .. text .. " --", { padding = { left = 1, right = 3 } })
    -- return status.utils.stylize(text, { padding = { left = 1, right = 3 } })
  end
end

local function search_count(opts)
  local search_func = vim.tbl_isempty(opts or {}) and function() return vim.fn.searchcount() end
    or function() return vim.fn.searchcount(opts) end
  return function()
    local search_ok, search = pcall(search_func)
    if search_ok and type(search) == "table" and search.total then
      return status.utils.stylize(
        string.format(
          "[%s%d/%s%d]",
          search.current > search.maxcount and ">" or "",
          math.min(search.current, search.maxcount),
          search.incomplete == 2 and ">" or "",
          math.min(search.total, search.maxcount)
        ),
        opts
      )
    end
  end
end

-- Statusline components table
return {
  -- default highlight for the entire statusline
  hl = { fg = "fg", bg = "bg" },

  -- add the vim mode component
  status.component.builder {
    hl = mode_hl,
    condition = function() return vim.opt.cmdheight:get() == 0 or not vim.opt.showmode:get() end,
    provider = mode_text(),
    update = {
      "ModeChanged",
      pattern = "*:*",
      callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
    },
  },
  -- add a section for the currently opened file information
  status.component.builder {
    fallthrough = false,
    {
      condition = is_valid_file_condition,
      flexible = 1,
      status.component.file_info {
        file_icon = false,
        filename = { modify = ":~:." },
        file_modified = { str = "[+]", icon = "" },
        file_read_only = { str = "[-]", icon = "" },
      },
      status.component.file_info {
        file_icon = false,
        filename = {},
        file_modified = { str = "[+]", icon = "" },
        file_read_only = { str = "[-]", icon = "" },
        unique_path = {}
      },
    },
    status.component.file_info { file_icon = false, filetype = {}, filename = false, file_modified = false, file_read_only = false },
  },
  -- add a component for the current diagnostics if it exists
  status.component.diagnostics {
    ERROR = { icon = { kind = "DiagnosticError1", padding = { left = 1, right = 0 } } },
    WARN = { icon = { kind = "DiagnosticWarn1", padding = { left = 1, right = 0 } } },
    INFO = { icon = { kind = "DiagnosticInfo1", padding = { left = 1, right = 0 } } },
    HINT = { icon = { kind = "DiagnosticHint1", padding = { left = 1, right = 0 } } },
    surround = { separator = "left" },
    on_click = {
      name = "heirline_diagnostic",
      callback = function()
        if is_available "telescope.nvim" then
          vim.defer_fn(function() require("telescope.builtin").diagnostics({ bufnr = 0 }) end, 100)
        end
      end,
    },
  },
  -- fill the rest of the statusline
  -- the elements after this will appear on the right of the statusline
  status.component.fill(),
  -- add a component for search count and macro recording status
  status.component.builder {
    {
      condition = status.condition.is_statusline_showcmd,
      provider = status.provider.showcmd()
    },
    {
      condition = status.condition.is_hlsearch,
      provider = search_count {},
    },
    {
      condition = status.condition.is_macro_recording,
      provider = status.provider.macro_recording { prefix = "recording @", padding = { left = 3 }  },
      update = {
        "RecordingEnter",
        "RecordingLeave",
        callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end) or nil,
      },
    },
    padding = { right = 5 },
    surround = {
      separator = "right",
      color = "cmd_info_bg",
      condition = function()
        return status.condition.is_hlsearch() or status.condition.is_macro_recording() or status.condition.is_statusline_showcmd()
      end,
    },
    condition = function() return vim.opt.cmdheight:get() == 0 end,
    hl = status.hl.get_attributes "cmd_info",
  },
  -- add a ruler navigation component
  status.component.builder {
    provider = status.provider.ruler { padding = { right = 5 } },
    surround = { separator = "right" },
    update = { "CursorMoved", "CursorMovedI", "BufEnter" },
  },
  -- add a percentage navigation component
  status.component.builder {
    provider = " %P ",
    surround = { separator = "right" }
  },
  -- statusline is cut here when there is not enough space
  { provider = '%<'}
}
