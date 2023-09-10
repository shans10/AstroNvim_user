local is_available = require "astronvim.utils".is_available
local status = require "astronvim.utils.status"

-- Mode text and highlights
local modes = {
  ["n"] = { "<N>", "normal" },
  ["no"] = { "<OP>", "normal" },
  ["nov"] = { "<OP>", "normal" },
  ["noV"] = { "<OP>", "normal" },
  ["no"] = { "<OP>", "normal" },
  ["niI"] = { "<N>", "normal" },
  ["niR"] = { "<N>", "normal" },
  ["niV"] = { "<N>", "normal" },
  ["i"] = { "<I>", "insert" },
  ["ic"] = { "<I>", "insert" },
  ["ix"] = { "<I>", "insert" },
  ["t"] = { "<T>", "terminal" },
  ["nt"] = { "<T>", "terminal" },
  ["v"] = { "<V>", "visual" },
  ["vs"] = { "<V>", "visual" },
  ["V"] = { "<Vl>", "visual" },
  ["Vs"] = { "<Vl>", "visual" },
  [""] = { "<Vb>", "visual" },
  ["s"] = { "<Vb>", "visual" },
  ["R"] = { "<R>", "replace" },
  ["Rc"] = { "<R>", "replace" },
  ["Rx"] = { "<R>", "replace" },
  ["Rv"] = { "V-REPLACE", "replace" },
  ["s"] = { "<S>", "visual" },
  ["S"] = { "<S>", "visual" },
  [""] = { "<Vb>", "visual" },
  ["c"] = { "<COMMAND>", "command" },
  ["cv"] = { "<COMMAND>", "command" },
  ["ce"] = { "<COMMAND>", "command" },
  ["r"] = { "<PROMPT>", "inactive" },
  ["rm"] = { "<MORE>", "inactive" },
  ["r?"] = { "<CONFIRM>", "inactive" },
  ["!"] = { "<SHELL>", "inactive" },
  ["null"] = { "null", "inactive" },
}

-- A highlight function to return highlight based on vi mode
local function mode_hl()
  local mode_fg = status.env.modes[vim.fn.mode()][2]
  return { fg = mode_fg, bg = "bg", bold = true }
end

-- A condition function if diagnostic separator is required based on diagnostic count and type
local function diag_sep_condition(target)
  local count = 0
  local error = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity["ERROR"] })
  local warn = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity["WARN"] })
  local info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity["INFO"] })
  local hint = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity["HINT"] })
  local diag = { error, warn, info, hint }
  for i = target + 1, #diag do
    count = count + diag[i]
  end
  return diag[target] > 0 and count > 0
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
    return status.utils.stylize("-- " .. text .. " --", { padding = { left = 1, right = 2 } })
  end
end

-- A provider function to get current mode text shortened
local function mode_text_short()
  return function()
    local text = modes[vim.fn.mode()][1]
    return status.utils.stylize(text, { padding = { left = 1, right = 2 } })
  end
end

-- Statusline components table
return {
  -- default highlight for the entire statusline
  hl = { fg = "fg", bg = "bg" },

  -- add the vim mode component
  status.component.builder {
    hl = mode_hl,
    flexible = 1,
    {
      provider = mode_text(),
      update = {
        "ModeChanged",
        pattern = "*:*",
        callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
      },
    },
    { provider = mode_text_short() },
  },
  -- add a section for the currently opened file information
  status.component.builder {
    fallthrough = false,
    {
      condition = is_valid_file_condition,
      status.component.file_info {
        file_icon = false,
        filename = { fallback = "Empty" },
        file_modified = { str = "[+]", icon = "" },
        file_read_only = { str = "[-]", icon = "" },
        unique_path = {},
      },
    },
    -- status.component.file_info { file_icon = false, filetype = {}, filename = false, file_modified = false, file_read_only = false },
  },
  -- add a seperator before git components
  status.component.builder {
    condition = status.condition.is_git_repo,
    provider = status.provider.str { str = "⎪", padding = { right = 1 } }
  },
  -- add a component for the current git branch if it exists and use no separator for the sections
  status.component.git_branch {
    hl = { fg = "fg", bold = false },
    padding = { right = 0 },
    surround = { separator = "none" },
  },
  -- add a component for the current git diff if it exists and use no separator for the sections
  status.component.builder {
    flexible = 2,
    {
      status.component.git_diff {
        added = { icon = { kind = "GitAdd", padding = { left = 1, right = 0 } } },
        changed = { icon = { kind = "GitChange", padding = { left = 1, right = 0 } } },
        removed = { icon = { kind = "GitDelete", padding = { left = 1, right = 0 } } },
        padding = { right = 1 },
        surround = { separator = "none" },
      }
    },
    { provider = "" }
  },
  -- add a seperator between components
  status.component.builder {
    condition = function()
      return status.condition.is_hlsearch() or status.condition.is_macro_recording() or status.condition.is_statusline_showcmd()
    end,
    provider = status.provider.str { str = "⎪", padding = { right = 1 } }
  },
  -- add a component for search count and macro recording status
  status.component.cmd_info {
    condition = function()
      return status.condition.is_hlsearch() or status.condition.is_macro_recording() or status.condition.is_statusline_showcmd()
    end,
    search_count = { padding = { left = 0 } },
    surround = { separator = "none" }
  },
  -- fill the rest of the statusline
  -- the elements after this will appear on the right of the statusline
  status.component.fill(),
  -- add a component to show lsp progress
  status.component.lsp { lsp_client_names = false, lsp_progress = { padding = { right = 1 } } },
  -- add a component for the current diagnostics if it exists
  status.component.builder {
    hl = { fg = "fg" },
    flexible = 4,
    {
      { provider = status.provider.diagnostics { severity = "ERROR" }, hl = { fg = "diag_ERROR" } },
      {
        condition = function() return diag_sep_condition(1) end,
        provider = "/",
      },
      { provider = status.provider.diagnostics { severity = "WARN" }, hl = { fg = "diag_WARN" } },
      {
        condition = function() return diag_sep_condition(2) end,
        provider = "/",
      },
      { provider = status.provider.diagnostics { severity = "INFO" }, hl = { fg = "diag_INFO" } },
      {
        condition = function() return diag_sep_condition(3) end,
        provider = "/",
      },
      { provider = status.provider.diagnostics { severity = "HINT" }, hl = { fg = "diag_HINT" } },
      update = { "DiagnosticChanged", "BufEnter" },
    },
    { provider = "" },
    on_click = {
      name = "heirline_diagnostic",
      callback = function()
        if is_available "telescope.nvim" then
          vim.defer_fn(function() require("telescope.builtin").diagnostics({ bufnr = 0 }) end, 100)
        end
      end,
    },
  },
  -- add component to show lsp status text if lsp is active
  status.component.builder {
    condition = status.condition.lsp_attached,
    flexible = 3,
    {
      provider = status.provider.str { str = "[LSP]", padding = { left = 1, right = 0 } },
      on_click = {
        name = "heirline_lsp",
        callback = function()
          vim.defer_fn(function() vim.cmd.LspInfo() end, 100)
        end,
      },
      update = {
        "LspAttach",
        "LspDetach",
        "BufEnter",
        callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
      },
    },
    { provider = "" }
  },
  -- add treesitter component
  status.component.builder {
    flexible = 3,
    status. component.treesitter {
      str = { str = " ", icon = { kind = "ActiveTS" } },
      surround = { separator = "none", },
    },
    { provider = "" }
  },
  -- add a seperator between components
  status.component.builder {
    condition = status.condition.lsp_attached or status.condition.treesitter_available,
    flexible = 3,
    { provider = status.provider.str { str = "⎪" } },
    { provider = "" }
  },
  -- add a component to show filetype
  status.component.file_info {
    filetype = {},
    filename = false,
    file_modified = false,
    file_read_only = false,
    surround = { separator = "none" }
  },
  -- add a seperator between components
  status.component.builder {
    condition = status.condition.has_filetype,
    provider = status.provider.str { str = "⎪", padding = { left = 1, right = 1 } }
  },
  -- add a ruler navigation component
  status.component.builder {
    { provider = status.provider.ruler { padding = { right = 1 } }, },
    update = { "CursorMoved", "CursorMovedI", "BufEnter" },
  },
  -- add a percentage navigation component
  status.component.builder {
    flexible = 5,
    {
      { provider = status.provider.str { str = "⎪" } },
      { provider = " %P " },
    },
    { provider = "" }
  },
  -- statusline is cut here when there is not enough space
  { provider = '%<'}
}
