local M = {}

M.pick_win = function(opts)
  opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  local tabpage = vim.api.nvim_get_current_tabpage()
  local win_ids = vim.api.nvim_tabpage_list_wins(tabpage)
  if opts.filter ~= nil then
    win_ids = vim.tbl_filter(opts.filter, win_ids)
  end

  if #win_ids == 0 then
    return nil
  end
  if #win_ids == 1 then
    return win_ids[1]
  end
  if #opts.chars < #win_ids then
    vim.notify("Too many windows to pick from (Update `chars`)", vim.log.levels.ERROR)
    return nil
  end

  local win_map = {}
  local win_float_map = {}

  for index, win_id in ipairs(win_ids) do
    local char = opts.chars:sub(index, index)

    local win_width = vim.api.nvim_win_get_width(win_id)
    local win_height = vim.api.nvim_win_get_height(win_id)

    local float_buf_id = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_lines(
      float_buf_id,
      0,
      -1,
      true,
      { '', '  ' .. char .. '  ', '' }
    )

    local float_win_id = vim.api.nvim_open_win(float_buf_id, false, {
      relative = 'win',
      win = win_id,
      row = win_height / 2 - 1.5,
      col = win_width / 2 - 2.5,
      width = 5,
      height = 3,
      focusable = false,
      style = 'minimal',
      noautocmd = true,
    })


    if opts.hl_group ~= nil then
      vim.api.nvim_set_option_value(
        'winhl',
        'Normal:' .. opts.hl_group,
        {win = float_win_id}
      )
    end

    win_map[char] = win_id
    win_float_map[float_win_id] = float_buf_id
  end

  vim.cmd.redraw()
  -- wait for a valid input
  local c = vim.fn.getchar()
  while type(c) ~= "number" do
    c = vim.fn.getchar()
  end
  local resp = (c == 27 and "") or (vim.fn.nr2char(c) or ""):upper() -- handle ESC separately


  for float_win_id, float_buf_id in pairs(win_float_map) do
    vim.api.nvim_win_close(float_win_id, true)
    vim.api.nvim_buf_delete(float_buf_id, { force = true })
  end

  if resp == "" then
    return nil
  end
  if not vim.tbl_contains(vim.split(opts.chars, ""), resp) then
    vim.notify("Invalid input: '" .. resp .. "'", vim.log.levels.ERROR)
    return nil
  end

  return win_map[resp]
end

M.opts = {
  chars = "1234567890",
  filter = nil,
  hl_group = nil,
}

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
end

return M
