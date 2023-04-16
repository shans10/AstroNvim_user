local status = require("astronvim.utils.status")

-- default statusline with filename instead of filetype
return {
  hl = { fg = "fg", bg = "bg" },
  status.component.mode(),
  status.component.git_branch(),
  status.component.file_info { unique_path = {} },
  status.component.git_diff(),
  status.component.diagnostics(),
  status.component.fill(),
  status.component.cmd_info(),
  status.component.fill(),
  status.component.lsp(),
  status.component.treesitter(),
  status.component.nav(),
  status.component.mode { surround = { separator = "right" } },
}
