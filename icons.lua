local icons = {
  BookMark = "",
  FileNew = "",
  FileRecent = "",
  Find = "",
  GitBranch = "",
  Plugin = "",
  Project = "",
  Reload = "",
}

-- Set icons based on chosen heirline-statusline theme
--
-- Get current statusline theme
local heirline_theme = vim.g.heirline_theme

-- Doom theme
if heirline_theme == "doom" then
  icons.ActiveLSP = ""
  icons.Bar = "┃"
  icons.Directory = ""
  icons.DoomFileModified = "󰳻"
  icons.DoomMode = ""
  icons.EvilMode = ""
  icons.GitChanges = ""

-- Lunarvim theme
elseif heirline_theme == "lunarvim" then
  icons.ActiveTS = ""
  icons.DefaultFile = ""
  icons.GitAdd = ""
  icons.GitChange = ""
  icons.GitDelete = ""
  icons.Mode = "󰀘"
  icons.Separator = "⎪"
  icons.Shiftwidth = "󰌒"

-- Nvchad theme
elseif heirline_theme == "nvchad" then
  icons.GitBranch = ""
  icons.GitAdd = ""
  icons.GitChange = ""
  icons.GitDelete = ""
  icons.ScrollText = ""
  icons.VimIcon = ""

-- Simple theme
elseif heirline_theme == "simple" then
  icons.ActiveTS = ""
  icons.Bar = "┃"
  icons.GitBranch = ""
  icons.GitAdd = "+"
  icons.GitChange = "~"
  icons.GitDelete = "-"

-- Minimal theme
elseif heirline_theme == "minimal" then
  icons.DiagnosticError = "x"
  icons.DiagnosticHint = "?"
  icons.DiagnosticInfo = "i"
  icons.DiagnosticWarn = "!"
end

return icons
