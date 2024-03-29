return {
  opt = {
    cmdheight = 1, -- enable cmd area
    list = true, -- enable whitespace rendering
    -- listchars = vim.opt.listchars:append({ tab = '› ', trail = '•', lead = '.', extends = '#', nbsp = '.' }), -- change whitespace characters
    listchars = vim.opt.listchars:append { tab = "› ", trail = "•" }, -- change whitespace characters
    scrolloff = 9, -- keep scroll position away from edges
    -- showcmdloc = "statusline", -- show cmd status in statusline
    showtabline = 0, -- disable tabline
    swapfile = false, -- disable swapfile creation
    title = true, -- enable neovim to set terminal title
    titlestring = [[%{substitute(getcwd(), $HOME, '~', '')} - AstroNvim]], -- set titlestring to be displayed
    whichwrap = vim.opt.whichwrap:append "<,>[,],h,l", -- automatically go to next line
  },
  g = {
    autoformat_enabled = false, -- enable or disable auto formatting at start (lsp.formatting.format_on_save must be enabled)
    breadcrumbs = false, -- disable winbar breadcrumbs(only works with lunarvim and no/default theme)
    -- heirline_theme = "lunarvim", -- set heirline statusline theme (possible options are doom, lunarvim, minimal, nvchad), comment/remove this option to choose default astronvim statusline
    winbar_enabled = false, -- enable winbar (set false to disable it, removing this option will have no effect)
  },
}
