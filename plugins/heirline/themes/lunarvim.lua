local get_icon = require("astronvim.utils").get_icon
local separator = get_icon "Separator" -- separator icon
local is_available = require "astronvim.utils".is_available
local status = require "astronvim.utils.status"

-- A highlight function to return highlight based on vi mode
local function mode_hl()
  local mode_bg = status.env.modes[vim.fn.mode()][2]
  return { fg = "#000000", bg = mode_bg }
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
local function shiftwidth_provider()
  local shiftwidth = vim.api.nvim_buf_get_option(0, "shiftwidth")
  return status.utils.stylize(
    status.utils.pad_string(get_icon "Shiftwidth", { right = 1 }) .. shiftwidth, { padding = { right = 1 } }
  )
end

-- Statusline components table
return {
  -- default highlight for the entire statusline
  hl = { fg = "fg", bg = "bg" },
  -- each element following is a component in st module

  -- add the vim mode component
  status.component.builder {
    -- set foreground highlight for mode icon
    hl = { fg = "bg" },
    -- set mode icon and hl
    {
      provider = status.utils.pad_string(get_icon "Mode", { left = 1, right = 1 }),
      hl = mode_hl
    },
    update = "ModeChanged",
  },
  -- add a component for the current git branch if it exists and use no separator for the sections
  status.component.builder {
    condition = status.condition.is_git_repo,
    hl = { fg = "git_branch_fg", bg = "git_branch_bg" },
    {
      provider = status.utils.pad_string(get_icon "GitBranch", { left = 1, right = 1 }),
      hl = { fg = "git_branch_icon" },
    },
    {
      provider = status.provider.git_branch { padding = { right = 1 } },
    },
    on_click = {
      name = "heirline_branch",
      callback = function()
        if is_available "telescope.nvim" then
          vim.defer_fn(function() require("telescope.builtin").git_branches() end, 100)
        end
      end,
    },
    update = { "User", pattern = "GitSignsUpdate" },
    init = status.init.update_events { "BufEnter" },
  },
  -- add a component for the current git diff if it exists and use no separator for the sections
  status.component.git_diff { padding = { left = 1 }, surround = { separator = "none" } },
  -- fill the rest of the statusline
  -- the elements after this will appear in the middle of the statusline
  status.component.fill(),
  status.component.cmd_info(),
  status.component.fill(),
  -- add a component to show lsp progress
  status.component.builder {
    flexible = 1,
    {
      condition = function() return vim.bo.filetype ~= "haskell" end,
      provider = status.provider.lsp_progress { padding = { right = 1 } }
    },
    { provider = "" },
    update = { "User", pattern = { "LspProgressUpdate", "LspRequest" } },
  },
  -- add a component for the current diagnostics if it exists
  status.component.diagnostics {
    surround = { separator = "right" },
    on_click = {
      name = "heirline_diagnostic",
      callback = function()
        if is_available "telescope.nvim" then
          vim.defer_fn(function() require("telescope.builtin").diagnostics({ bufnr = 0 }) end, 100)
        end
      end,
    },
  },
  -- add a component to show running lsp clients
  status.component.builder {
    fallthrough = false,
    hl = { bold = true },
    {
      condition = status.condition.lsp_attached,
      {
        flexible = 2,
        {
          provider = lsp_clients_provider,
        },
        { provider = status.provider.str { str = "[LS]", padding = { left = 1, right = 1 } } },
      },
    },
    { provider = status.provider.str { str = "LS Inactive", padding = { left = 1, right = 1 } } },
    on_click = {
      name = "heirline_lsp",
      callback = function()
        vim.defer_fn(function() vim.cmd.LspInfo() end, 100)
      end,
    },
  },
  -- add a component to show current shiftwidth(indent spaces) of a file
  status.component.builder {
    { provider = status.utils.pad_string(separator, { right = 1 }), hl = { fg = "separator_bg" } },
    { provider = shiftwidth_provider }
  },
  -- add a section to show opened filetype
  status.component.builder {
    condition = status.condition.has_filetype,
    { provider = status.utils.pad_string(separator, { right = 1 }), hl = { fg = "separator_bg" } },
    {
      provider = status.provider.file_icon { padding = { right = 1 } },
      hl = status.hl.filetype_color
    },
    { provider = status.provider.filetype { padding = { right = 2 } } }
  },
  -- add a navigation component
  status.component.builder {
    {
      provider = status.provider.ruler { padding = { left = 1, right = 1 } },
      hl = { fg = "ruler_fg", bg = "ruler_bg" }
    },
    {
      provider = " %P/%L ",
      hl = mode_hl
    },
    update = { "CursorMoved", "BufEnter", "ModeChanged" },
  }
}
