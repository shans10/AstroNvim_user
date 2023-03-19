-- Customize colors for each element each element has a `_fg` and a `_bg`
return function(colors)
  local get_hlgroup = require("astronvim.utils").get_hlgroup

  -- Bufferline
  colors.buffer_path_fg = get_hlgroup("NonText").fg

  -- Winbar
  colors.winbar_fg = get_hlgroup("NonText").fg
  colors.winbarnc_fg = get_hlgroup("NonText").fg

  -- Set colors based on chosen heirline statusline theme
  --
  -- Get current statusline theme
  local theme = vim.g.heirline_theme

  -- Doom theme
  if theme == "doom" then
    local search = get_hlgroup("IncSearch")
    local typedef = get_hlgroup("TypeDef")
    colors.search_fg = search.fg
    colors.search_bg = search.bg
    colors.work_dir_fg = typedef.fg

    -- Lunarvim theme
  elseif theme == "lunarvim" then
    local constant_fg = get_hlgroup("Constant").fg
    local cursorline_bg = get_hlgroup("CursorLine").bg
    local normal_fg = get_hlgroup("Normal").fg
    colors.git_branch_bg = cursorline_bg
    colors.git_branch_fg = normal_fg
    colors.git_branch_icon = constant_fg
    colors.ruler_fg = normal_fg
    colors.ruler_bg = cursorline_bg
    colors.separator_bg = cursorline_bg

    -- Nvchad theme
  elseif theme == "nvchad" then
    local comment_fg = get_hlgroup("Comment").fg
    colors.git_branch_fg = comment_fg
    colors.git_added = comment_fg
    colors.git_changed = comment_fg
    colors.git_removed = comment_fg
    colors.blank_bg = get_hlgroup("WildMenu").bg
    colors.file_info_bg = get_hlgroup("Visual").bg
    colors.nav_icon_bg = get_hlgroup("String").fg
    colors.nav_fg = colors.nav_icon_bg
    colors.folder_icon_bg = get_hlgroup("Error").fg
  end

  return colors
end
