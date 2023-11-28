local event = require('nui.utils.autocmd').event

local scratch = {}

scratch.content = nil
scratch.cursor = nil

scratch.setup = function(user_config)
  local function store_buffer_state(bufnr)
    if vim.api.nvim_buf_is_loaded(bufnr) then
      scratch.content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      scratch.cursor = vim.api.nvim_win_get_cursor(0)
    end
  end

  local function restore_buffer_state(bufnr)
    if scratch.content and vim.api.nvim_buf_is_loaded(bufnr) then
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, scratch.content)
    end
    if scratch.cursor then vim.api.nvim_win_set_cursor(0, scratch.cursor) end
  end

  -- Merge user_config with default configuration
  local config = vim.tbl_deep_extend('keep', user_config or {}, {
    -- Default configuration values
    default_width = 0.30,
    default_height = 0.40,
    border_style = 'rounded',
    border_text = '   Scratch file ',
    border_padding_top = 1,
    border_padding_left = 3,
    highlight = 'Normal:Normal,FloatBorder:SpecialChar',
    position = {
      row = '50%',
      col = '50%',
    },
  })

  scratch.open_buffer = function(filetype, width, height)
    local win_width = vim.o.columns
    local win_height = vim.o.lines

    local popup_width = width or math.floor(win_width * config.default_width)
    local popup_height = height or math.floor(win_height * config.default_height)

    local bufnr = vim.api.nvim_create_buf(false, true)

    if filetype then vim.api.nvim_buf_set_option(bufnr, 'filetype', filetype) end

    local Popup = require('nui.popup')

    if popup and vim.api.nvim_buf_is_loaded(bufnr) then
      restore_buffer_state(bufnr)
      popup:show()
      return
    end

    local popup = Popup({
      enter = true,
      focusable = true,
      border = {
        style = config.border_style,
        text = {
          top = config.border_text,
          top_align = 'center',
        },
        padding = {
          top = config.border_padding_top,
          left = config.border_padding_left,
        },
      },
      win_options = {
        winhighlight = config.highlight,
      },

      size = {
        width = popup_width,
        height = popup_height,
      },
      position = {
        row = config.position.row,
        col = config.position.col,
      },
    })

    popup.border:set_highlight('Normal')

    popup:on(event.BufLeave, function()
      scratch.content = vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false)
      scratch.cursor = vim.api.nvim_win_get_cursor(0)
    end)

    popup:on(event.BufWinEnter, function()
      if scratch.cursor and scratch.content then
        vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, scratch.content)
        vim.api.nvim_win_set_cursor(0, scratch.cursor)
      end
    end)

    vim.api.nvim_buf_set_keymap(
      bufnr,
      'n',
      'q',
      ':lua require("scratch").hide_buffer()<CR>',
      { noremap = true, silent = true }
    )

    popup:mount()
  end

  scratch.hide_buffer = function()
    if popup then
      store_buffer_state(popup.bufnr)
      popup:hide()
    end
  end
end

return scratch
