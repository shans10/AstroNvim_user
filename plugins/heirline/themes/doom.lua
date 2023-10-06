local get_icon = require("astronvim.utils").get_icon
local is_available = require("astronvim.utils").is_available
local status = require "astronvim.utils.status"

-- Mode text and highlights
-- local modes = {
--   ["n"] = { "<N>", "normal" },
--   ["no"] = { "<OP>", "normal" },
--   ["nov"] = { "<OP>", "normal" },
--   ["noV"] = { "<OP>", "normal" },
--   ["no"] = { "<OP>", "normal" },
--   ["niI"] = { "<N>", "normal" },
--   ["niR"] = { "<N>", "normal" },
--   ["niV"] = { "<N>", "normal" },
--   ["i"] = { "<I>", "insert" },
--   ["ic"] = { "<I>", "insert" },
--   ["ix"] = { "<I>", "insert" },
--   ["t"] = { "<T>", "terminal" },
--   ["nt"] = { "<T>", "terminal" },
--   ["v"] = { "<V>", "visual" },
--   ["vs"] = { "<V>", "visual" },
--   ["V"] = { "<Vl>", "visual" },
--   ["Vs"] = { "<Vl>", "visual" },
--   [""] = { "<Vb>", "visual" },
--   ["s"] = { "<Vb>", "visual" },
--   ["R"] = { "<R>", "replace" },
--   ["Rc"] = { "<R>", "replace" },
--   ["Rx"] = { "<R>", "replace" },
--   ["Rv"] = { "V-REPLACE", "replace" },
--   ["s"] = { "<S>", "visual" },
--   ["S"] = { "<S>", "visual" },
--   [""] = { "<Vb>", "visual" },
--   ["c"] = { "<COMMAND>", "command" },
--   ["cv"] = { "<COMMAND>", "command" },
--   ["ce"] = { "<COMMAND>", "command" },
--   ["r"] = { "<PROMPT>", "inactive" },
--   ["rm"] = { "<MORE>", "inactive" },
--   ["r?"] = { "<CONFIRM>", "inactive" },
--   ["!"] = { "<SHELL>", "inactive" },
--   ["null"] = { "null", "inactive" },
-- }

-- A provider function to get current mode text
-- local function mode_text()
--   return function()
--     local text = modes[vim.fn.mode()][1]
--     return status.utils.stylize(text, { padding = { right = 3 } })
--   end
-- end

-- A highlight function to return highlight for modified files
local function file_modified_hl(default)
  if vim.bo.modified then
    return { fg = "diag_ERROR" }
  else
    return { fg = default }
  end
end

-- An `init` function to build full file path
local function file_path_init(self)
  local bufnr = self and self.bufnr or 0
  local os_sep = package.config:sub(1, 1)
  local pwd = vim.fn.getcwd(bufnr) -- Present working directory.
  local current_path = vim.api.nvim_buf_get_name(bufnr)

  if current_path == "" then
    pwd = vim.fn.fnamemodify(pwd, ":t")
    current_path = nil
  elseif current_path:find(pwd, 1, true) then
    current_path = vim.fn.fnamemodify(current_path, ":~:.:h")
    pwd = vim.fn.fnamemodify(pwd, ":t") .. os_sep
    if current_path == "." then
      current_path = nil
    else
      current_path = current_path .. os_sep
    end
  else
    pwd = nil
    current_path = vim.fn.fnamemodify(current_path, ":~:.:h") .. os_sep
  end

  self.pwd = pwd
  self.current_path = current_path -- The opened file path relevant to pwd.
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
  return not status.condition.buffer_matches({
    buftype = { "nofile", "prompt", "quickfix" },
    filetype = { "^git.*", "fugitive", "toggleterm", "NvimTree" },
  }, bufnr)
end

-- A condition function to check if visual mode is active
local function is_visual_mode_condition()
  return (vim.fn.mode():find "[Vv]" ~= nil or vim.fn.mode():find "[^V]" ~= nil) and vim.fn.mode():find "[n]" == nil
end

-- A provider function for current relative path
local function current_path_provider(opts)
  return function(self)
    local bufnr = self and self.bufnr or 0
    return status.utils.stylize(vim.bo[bufnr].filetype ~= "help" and self.current_path, opts)
  end
end

-- A provider function for cwd
local function cwd_provider(opts)
  return function(self)
    local cwd = vim.fn.getcwd(0)
    local icon = status.utils.pad_string(get_icon "Directory", { left = 1, right = 1 })
    self.cwd = vim.fn.fnamemodify(cwd, ":t")
    return status.utils.stylize(icon .. self.cwd, opts)
  end
end

-- A provider function for current file size
local function file_size_provider(opts)
  return function(self)
    local no_search = not status.condition.is_hlsearch()
    local suffix = { "b", "k", "M", "G", "T", "P", "E" }
    local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(self and self.bufnr or 0))
    fsize = (fsize < 0 and 0) or fsize
    if fsize < 1000 then return status.utils.stylize(no_search and fsize .. suffix[1], opts) end
    local i = math.floor((math.log(fsize) / math.log(1000)))
    return status.utils.stylize(no_search and string.format("%.2g%s", fsize / 1000 ^ i, suffix[i + 1]), opts)
  end
end

-- A provider function for current filetype
local function filetype_provider(opts)
  return function(self)
    local buffer = vim.bo[self and self.bufnr or 0]
    return status.utils.stylize(buffer.filetype:gsub("^%l", string.upper), opts)
  end
end

-- A provider function for total git changes
local function git_changes_provider(opts)
  return function(self)
    local git_status = vim.b[self and self.bufnr or 0].gitsigns_status_dict
    local icon = status.utils.pad_string(get_icon "GitChanges", { left = 1, right = 1 })
    local count = git_status.added + git_status.removed + git_status.changed
    return status.utils.stylize(icon .. count, opts)
  end
end

-- A provider function for cwd as path
local function work_dir_provider(opts)
  return function(self)
    local bufnr = self and self.bufnr or 0
    return status.utils.stylize(vim.bo[bufnr].filetype ~= "help" and self.pwd, opts)
  end
end

-- Statusline components table
return {
  -- default highlight for the entire statusline
  hl = { fg = "fg", bg = "bg" },
  -- each element following is a component in st module

  -- add a bar on left corner before mode
  status.component.builder {
    hl = { fg = "normal" },
    provider = get_icon "Bar",
    surround = { separator = "left" },
  },
  -- add the vim mode component
  status.component.builder {
    hl = function() return { fg = status.hl.mode_bg() } end,
    provider = get_icon "EvilMode",
    surround = { separator = "left" },
    update = {
      "ModeChanged",
      pattern = "*:*",
      callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
    },
  },
  -- add the vim mode component
  -- status.component.builder {
  --   hl = function() return { fg = status.hl.mode_bg(), bold = true } end,
  --   provider = mode_text(),
  --   update = {
  --     "ModeChanged",
  --     pattern = "*:*",
  --     callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
  --   },
  -- },
  -- add a component for search results
  status.component.builder {
    condition = function() return status.condition.is_hlsearch() end,
    hl = { fg = "search_fg" },
    provider = status.provider.search_count { padding = { left = 1, right = 1 } },
    surround = {
      separator = "left",
      color = "search_bg",
      condition = function() return status.condition.is_hlsearch() end,
    },
  },
  -- add component to show current buffer size
  status.component.builder {
    condition = is_valid_file_condition,
    provider = file_size_provider { padding = { left = 1, right = 3 } },
  },
  -- add component to show full file path
  status.component.builder {
    fallthrough = false,
    {
      condition = is_valid_file_condition,
      hl = { fg = "file_info_fg", bold = true },
      { provider = status.provider.file_icon { padding = { right = 1 } }, hl = status.hl.filetype_color },
      {
        provider = status.provider.file_modified { icon = { kind = "DoomFileModified" }, padding = { right = 1 } },
        hl = { fg = "diag_ERROR" },
      },
      {
        flexible = 1,
        {
          provider = work_dir_provider(),
          hl = function() return file_modified_hl "work_dir_fg" end,
        },
        { provider = "" },
      },
      {
        flexible = 2,
        {
          provider = current_path_provider(),
          hl = function() return file_modified_hl "visual" end,
        },
        { provider = "" },
      },
      {
        provider = status.provider.filename { padding = { right = 1 } },
        hl = function() return file_modified_hl() end,
      },
      { provider = status.provider.file_read_only(), hl = { fg = "diag_WARN" } },
      { provider = "%<" },
      init = file_path_init,
    },
    {
      hl = { fg = "treesitter_fg", bold = true },
      provider = cwd_provider { padding = { left = 1, right = 1 } },
    },
    surround = { separator = "left" },
  },
  -- add a navigation component and just display the percentage of progress in the file
  status.component.nav {
    -- add some padding for the percentage provider
    percentage = { padding = { left = 2 } },
    -- disable all other providers
    ruler = {},
    scrollbar = false,
    -- use no separator and define the background color
    surround = { separator = "none", color = "file_info_bg" },
  },
  -- add a component to show number of selected lines
  status.component.cmd_info {
    condition = is_visual_mode_condition,
    hl = { fg = "lines_fg" },
    macro_recording = false,
    search_count = false,
  },
  -- fill the rest of the statusline
  -- the elements after this will appear in the right side of the statusline
  status.component.fill(),
  -- add a component to show lsp progress
  status.component.lsp {
    condition = function() return not require("astronvim.utils").is_available "noice.nvim" end,
    lsp_client_names = false,
    surround = { separator = "right", color = "bg" },
  },
  -- add a component for the current diagnostics if it exists
  status.component.builder {
    hl = { fg = "fg" },
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
    on_click = {
      name = "heirline_diagnostic",
      callback = function()
        if is_available "telescope.nvim" then
          vim.defer_fn(function() require("telescope.builtin").diagnostics { bufnr = 0 } end, 100)
        end
      end,
    },
    update = { "DiagnosticChanged", "BufEnter" },
  },
  -- add component to show lsp status icon if lsp is active
  status.component.builder {
    hl = { fg = "treesitter_fg" },
    condition = status.condition.lsp_attached,
    provider = status.utils.pad_string(get_icon "ActiveLSP", { right = 2 }),
    surround = { separator = "right", condition = status.condition.lsp_attached },
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
  -- add a component to show filetype for current file
  status.component.builder {
    condition = status.condition.has_filetype,
    hl = { fg = "work_dir_fg", bold = true },
    provider = filetype_provider { padding = { right = 1 } },
    surround = { separator = "right", condition = status.condition.has_filetype },
  },
  -- add a component for the current git branch if it exists
  status.component.git_branch {
    surround = { separator = "right" },
    git_branch = { padding = { right = 1 } },
  },
  -- add a component for the total git changes if there are any
  status.component.builder {
    condition = status.condition.git_changed,
    hl = { fg = "command", bold = true },
    provider = git_changes_provider { padding = { right = 1 } },
    on_click = {
      name = "heirline_git",
      callback = function()
        if is_available "telescope.nvim" then
          vim.defer_fn(function() require("telescope.builtin").git_status() end, 100)
        end
      end,
    },
    update = { "User", pattern = "GitSignsUpdate" },
    init = status.init.update_events { "BufEnter" },
  },
}
