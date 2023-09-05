return function()
  local get_hlgroup = require("astronvim.utils").get_hlgroup
  local blue = get_hlgroup("Directory").fg
  local grey = get_hlgroup("NonText").fg
  local red = get_hlgroup("Error").fg
  return {
    DashboardCenter = { fg = red },
    DashboardFooter = { fg = grey, italic = true },
    DashboardHeader = { fg = grey, italic = true },
    DashboardShortcut = { fg = blue },
    HighlightURL = { underline = true },
    WinBar = { fg = grey },
    WinBarNC = { fg = grey },
    -- Transparency
    -- CursorLine = { bg = "NONE" },
    -- EndOfBuffer = { bg = "NONE" },
    -- NeoTreeNormal = { bg = "NONE" },
    -- NeoTreeNormalNC = { bg = "NONE" },
    -- Normal = { bg = "NONE" },
    -- NormalFloat = { bg = "NONE" },
    NormalNC = { bg = "NONE" },
  }
end
