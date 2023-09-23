return function()
  local get_hlgroup = require("astronvim.utils").get_hlgroup
  local grey = get_hlgroup("NonText").fg
  return {
    HighlightURL = { underline = true },
    WinBar = { fg = grey },
    WinBarNC = { fg = grey },

    -- Transparency
    NormalNC = { bg = "NONE" },
  }
end
