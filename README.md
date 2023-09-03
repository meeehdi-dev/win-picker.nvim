# Win-picker.nvim

Win-picker allows you to quickly focus any window in your tabpane.

It is inspired by the default window picker of [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua).

![demo](https://github.com/meeehdi-dev/win-picker.nvim/assets/3422399/33c06659-782b-40cb-8255-a61b120af159)

## Configuration

Here is the default configuration.

- `chars` is a string defining the characters used to select the window.
- `filter` is a function receiving a win_id as parameter and returning a boolean to filter out a window.
- `hl_current` is either a boolean to highlight or not the current window using the hl_group or a string designating an other predefined highlight group.
- `hl_group` is a string designating a predefined highlight group.
- `hl` defines a new hl group.

```lua
require('win-picker').setup({
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
})
```

## Usage

Install and configure using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
  return {
    'meeehdi-dev/win-picker.nvim',
    config = true, -- setup with default options
    keys = {
      {
        "<C-w>!" = function()
          local win_id = require("win-picker").pick_win()
          if win_id then
            vim.api.nvim_set_current_win(win_id)
          end
        end,
      },
    },
  },
  -- or
  return {
    'meeehdi-dev/win-picker.nvim',
    opts = {
      chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
      filter = function(id)
        local bufid = vim.api.nvim_win_get_buf(id)
        local ft = vim.api.nvim_buf_get_option(bufid, "filetype")
        return not vim.tbl_contains({"noice", "notify"}, ft)
      end,
      hl_current = "CustomHlGroupFromMyAwesomeTheme",
      hl = {
          group = "NvimTreeWinPickerStyle",
          gui = "bold",
          guifg = "#ededed",
          guibg = "#4493c8",
      },
    },
    keys = {
      {
        "<leader>w" = function()
          local win_id = require("win-picker").pick_win()
          if win_id then
            vim.api.nvim_set_current_win(win_id)
          end
        end,
      },
    },
  },
```

It can also be used as the window picker for nvim-tree
```lua
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      {
        "meeehdi-dev/win-picker.nvim",
        config = true,
      },
    },
    opts = {
      actions = {
        open_file = {
          window_picker = {
            picker = function()
              return require("win-picker").pick_win({
                -- you can set the same options as in the setup except for `hl`
                hl_group = "lualine_a_normal", -- use lualine normal mode hl group
              })
            end,
          },
        },
      },
    },
    -- ...
  },
```

