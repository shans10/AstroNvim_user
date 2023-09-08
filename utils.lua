M = {}

function M.better_search(key)
  return function()
    local searched, error =
        pcall(vim.cmd.normal, { args = { (vim.v.count > 0 and vim.v.count or "") .. key }, bang = true })
    if not searched and type(error) == "string" then require("astronvim.utils").notify(error, vim.log.levels.ERROR) end
    pcall(vim.cmd.normal, "zzzv")
    vim.opt.hlsearch = searched
  end
end

function M.last_buffer()
  return function()
    local success, _ = pcall(function() vim.cmd "e #" end)
    if not success then
      local error = "No other buffer to switch to"
      require("astronvim.utils").notify(error, vim.log.levels.ERROR)
    end
  end
end

return M
