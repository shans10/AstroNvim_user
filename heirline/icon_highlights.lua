-- Customize if icons should be highlighted
return {
  breadcrumbs = true,                                                                          -- LSP symbols in the breadcrumbs
  file_icon = {
    winbar = function() return require "astronvim.utils.status".condition.is_active() end,     -- filetype icon in the winbar based on winbar status
  },
}
