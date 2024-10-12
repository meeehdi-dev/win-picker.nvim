---@alias Options { chars: string, filter?: function, hl_group?: string, callback: function | nil }

---@type Options
local options = {
  chars = "1234567890",
  filter = function(id)
    local buf = vim.api.nvim_win_get_buf(id)
    local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
    return not vim.tbl_contains({ "noice", "notify" }, ft)
  end,
}

---@param opts Options
local function set(opts)
  options = vim.tbl_deep_extend("force", options, opts or {})
end

---@return Options
local function get()
  return options
end

return {
  get = get,
  set = set,
}
