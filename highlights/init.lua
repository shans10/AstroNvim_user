return function()
  local get_hlgroup = require("astronvim.utils").get_hlgroup
  local grey = get_hlgroup("Comment").fg
  local notify_bg = get_hlgroup("StatusLine").bg
  local text = get_hlgroup("Normal").fg
  return {
    HighlightURL = { underline = true },
    NoiceMini = { bg = notify_bg },
    NotifyBackground = { bg = notify_bg },
    WinBar = { fg = text },
    WinBarNC = { fg = grey },

    -- Transparency
    NormalNC = { bg = "NONE" },
  }
end
