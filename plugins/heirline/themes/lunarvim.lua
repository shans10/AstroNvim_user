local get_icon = require("astronvim.utils").get_icon
local component_separator = get_icon "Separator" -- separator icon
local status = require "astronvim.utils.status"

-- A highlight function to return highlight based on vi mode
local function mode_hl()
  local mode_bg = status.env.modes[vim.fn.mode()][2]
  return { fg = "git_branch_bg", bg = mode_bg }
end

-- A condition function if buffer is a valid file
local function is_valid_file_condition(self)
  local bufnr = self and self.bufnr or 0
  return not status.condition.buffer_matches({
    buftype = { "nofile", "prompt", "quickfix" },
    filetype = { "^git.*", "fugitive", "toggleterm", "NvimTree" },
  }, bufnr)
end

-- A provider function for showing the connected LSP client names
local function lsp_clients_provider(self)
  local truncate = 0.25
  local buf_client_names = {}
  for _, client in pairs(vim.lsp.get_active_clients { bufnr = self and self.bufnr or 0 }) do
    if client.name == "null-ls" then
      local null_ls_sources = {}
      for _, type in ipairs { "FORMATTING", "DIAGNOSTICS" } do
        for _, source in ipairs(status.utils.null_ls_sources(vim.bo.filetype, type)) do
          null_ls_sources[source] = true
        end
      end
      vim.list_extend(buf_client_names, vim.tbl_keys(null_ls_sources))
    else
      table.insert(buf_client_names, client.name)
    end
  end
  local str = table.concat(buf_client_names, ", ")
  local max_width = math.floor(status.utils.width() * truncate)
  if #str > max_width then str = string.sub(str, 0, max_width) .. "…" end
  return status.provider.str { str = "[" .. str .. "]", padding = { left = 1, right = 1 } }
end

-- A provider function for showing current file's shiftwidth
-- local function shiftwidth_provider()
--   local shiftwidth = vim.api.nvim_buf_get_option(0, "shiftwidth")
--   return status.utils.stylize(
--     status.utils.pad_string(get_icon "Shiftwidth", { right = 1 }) .. shiftwidth, { padding = { right = 1 } }
--   )
-- end

-- Statusline components table
return {
  -- default highlight for the entire statusline
  hl = { fg = "fg", bg = "bg" },

  -- add the vim mode component
  status.component.builder {
    -- set foreground highlight for mode icon
    hl = { fg = "bg", bold = true },
    -- set mode text and hl
    {
      provider = status.provider.mode_text { padding = { left = 1, right = 1 } },
      hl = mode_hl,
    },
    update = {
      "ModeChanged",
      pattern = "*:*",
      callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
    },
  },
  -- add a section for the currently opened file information
  status.component.builder {
    condition = is_valid_file_condition,
    { provider = " ", hl = { bg = "file_bg" } },
    {
      flexible = 2,
      {
        status.component.file_info {
          file_icon = false,
          filename = { modify = ":.:" },
          file_modified = { str = "[+]", icon = "" },
          file_read_only = { str = "[-]", icon = "" },
          -- unique_path = {},
          padding = { right = 1 },
          surround = { separator = "none", color = "file_bg", condition = false },
        },
      },
      {
        status.component.file_info {
          file_icon = false,
          filename = {},
          file_modified = { str = "[+]", icon = "" },
          file_read_only = { str = "[-]", icon = "" },
          -- unique_path = {},
          padding = { right = 1 },
          surround = { separator = "none", color = "file_bg", condition = false },
        },
      },
    },
  },
  -- add a component for the current git branch if it exists
  status.component.builder {
    condition = status.condition.is_git_repo,
    {
      provider = status.utils.pad_string(get_icon "GitBranch", { left = 1, right = 1 }),
      hl = { fg = "git_branch_icon" },
    },
    { provider = status.provider.git_branch {} },
    padding = { right = 1 },
  },
  -- add a component for the current git diff if it exists
  status.component.builder {
    condition = status.condition.git_changed,
    status.component.git_diff {
      surround = { separator = "none", condition = status.condition.is_git_repo },
      padding = { right = 1 },
    },
  },
  -- fill the rest of the statusline
  -- the elements after this will appear in the middle of the statusline
  status.component.fill(),
  -- add a component for search count and macro recording status
  status.component.cmd_info { showcmd = false },
  -- fill the rest of the statusline
  -- the elements after this will appear on the right of the statusline
  status.component.fill(),
  -- statusline is cut here when there is not enough space
  { provider = "%<" },
  -- add a component to show lsp progress
  status.component.lsp {
    condition = function() return not require("astronvim.utils").is_available "noice.nvim" end,
    lsp_client_names = false,
    surround = { separator = "right", color = "bg" },
  },
  -- add a component for the current diagnostics if it exists
  status.component.diagnostics { surround = { separator = "right" } },
  -- add a component to show running lsp clients
  status.component.builder {
    fallthrough = false,
    hl = { bold = true },
    {
      condition = status.condition.lsp_attached,
      flexible = 1,
      { provider = lsp_clients_provider },
      { provider = status.provider.str { str = "[LS]", padding = { left = 1, right = 1 } } },
    },
    {
      flexible = 1,
      { provider = status.provider.str { str = "LS Inactive", padding = { left = 1, right = 1 } } },
      { provider = "" },
    },
    on_click = {
      name = "heirline_lsp",
      callback = function()
        vim.defer_fn(function() vim.cmd.LspInfo() end, 100)
      end,
    },
  },
  -- add a component to show treesitter status
  status.component.builder {
    condition = status.condition.treesitter_available,
    hl = status.hl.get_attributes "treesitter",
    update = { "OptionSet", pattern = "syntax" },
    init = status.init.update_events { "BufEnter" },
    provider = get_icon("ActiveTS", 1),
  },
  -- add a component to show current shiftwidth(indent spaces) of a file
  -- status.component.builder {
  --   { provider = status.utils.pad_string(separator, { right = 1 }), hl = { fg = "separator_fg" } },
  --   { provider = shiftwidth_provider }
  -- },
  -- add a section to show opened filetype
  status.component.builder {
    condition = status.condition.has_filetype,
    { provider = status.utils.pad_string(component_separator, { right = 1 }), hl = { fg = "separator_fg" } },
    {
      condition = is_valid_file_condition,
      provider = status.provider.file_icon { padding = { right = 1 } },
      hl = status.hl.filetype_color,
    },
    { provider = status.provider.filetype { padding = { right = 2 } } },
  },
  -- add a navigation component
  status.component.builder {
    {
      provider = " %P ",
      hl = { fg = "ruler_fg", bg = "ruler_bg" },
    },
    {
      provider = status.provider.ruler { padding = { left = 1, right = 1 } },
      update = { "CursorMoved", "CursorMovedI", "BufEnter" },
      hl = mode_hl,
    },
  },
}
