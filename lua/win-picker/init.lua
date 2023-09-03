local M = {}

local backed_up_opts = {"winhl", "statusline"}

local function backup_win_opts(win_id)
  local win_opts = {}
  for _, opt in ipairs(backed_up_opts) do
    win_opts[opt] = vim.api.nvim_win_get_option(win_id, opt)
  end
  return win_opts
end

local function restore_win_opts(win_id, win_opts)
  for opt, value in pairs(win_opts) do
    vim.api.nvim_win_set_option(win_id, opt, value)
  end
end

M.pick_win = function(opts)
  opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  local tabpage = vim.api.nvim_get_current_tabpage()
  local win_ids = vim.api.nvim_tabpage_list_wins(tabpage)
  if opts.filter ~= nil then
    win_ids = vim.tbl_filter(opts.filter, win_ids)
  end

  if #win_ids == 0 then
    vim.notify("No windows to pick from", vim.log.levels.ERROR)
    return nil
  end
  if #win_ids == 1 then
    vim.notify("Only one window", vim.log.levels.ERROR)
    return nil
  end
  if #opts.chars < #win_ids then
    vim.notify("Too many windows to pick from (Update `chars`)", vim.log.levels.ERROR)
    return nil
  end

  local win_opts = {}
  local win_map = {}
  local laststatus = vim.o.laststatus
  vim.o.laststatus = 2

  for i, id in ipairs(win_ids) do
    local char = opts.chars:sub(i, i)
    win_opts[id] = backup_win_opts(id)
    win_map[char] = id

    vim.api.nvim_win_set_option(id, "statusline", "%=" .. char .. "%=")
    if vim.api.nvim_get_current_win() ~= id then
      vim.api.nvim_win_set_option(id, "winhl", "StatusLine:" .. opts.hl_group .. ",StatusLineNC:" .. opts.hl_group)
    elseif opts.hl_current ~= false then
      local hl_group = opts.hl_current == true and opts.hl_group or opts.hl_current
      vim.api.nvim_win_set_option(id, "winhl", "StatusLine:" .. hl_group .. ",StatusLineNC:" .. hl_group)
    end
  end

  vim.cmd.redraw()
  -- wait for a valid input
  local c = vim.fn.getchar()
  while type(c) ~= "number" do
    c = vim.fn.getchar()
  end
  local resp = (vim.fn.nr2char(c) or ""):upper()

  for _, id in ipairs(win_ids) do
    restore_win_opts(id, win_opts[id])
  end

  vim.o.laststatus = laststatus

  if not vim.tbl_contains(vim.split(opts.chars, ""), resp) then
    vim.notify("Invalid input", vim.log.levels.ERROR)
    return nil
  end

  return win_map[resp]
end

M.opts = {
  chars = "1234567890",
  filter = nil,
  hl_current = false,
  hl_group = nil,
  hl = {
    group = "WinPicker",
    gui = "bold",
    guifg = "#1d202f",
    guibg = "#7aa2f7",
  },
}

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  if M.opts.hl_group == nil then
    M.opts.hl_group = M.opts.hl.group
    vim.api.nvim_command("hi def " .. M.opts.hl_group .. " gui=" .. M.opts.hl.gui .. " guifg=" .. M.opts.hl.guifg .. " guibg=" .. M.opts.hl.guibg)
  end
end

return M
