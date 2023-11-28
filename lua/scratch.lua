local event = require('nui.utils.autocmd').event

-- The `scratch` table holds the state and functionalities of the scratch buffer.
local scratch = {}

-- Initialize content and cursor positions to nil.
scratch.content = nil
scratch.cursor = nil

-- Initialize the popup window to nil.
local popup = nil

-- The `setup` function configures the scratch buffer's behavior and appearance.
-- @param user_config table The user-defined configuration options.
scratch.setup = function(user_config)
  -- Restore the buffer's state.
  -- @param bufnr number The buffer number.
  local function restore_buffer_state(bufnr)
    -- Restore content if it exists and the buffer is loaded.
    if scratch.content and vim.api.nvim_buf_is_loaded(bufnr) then
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, scratch.content)
    end
    -- Restore cursor position if it exists.
    if scratch.cursor then vim.api.nvim_win_set_cursor(0, scratch.cursor) end
  end

  -- Extend the default configuration with user-provided options.
  local config = vim.tbl_deep_extend('keep', user_config or {}, {
    -- Configuration for default dimensions and appearance of the popup.
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

  -- Open or update the scratch buffer in a popup window.
  -- @param filetype string The filetype of the buffer.
  -- @param width number The width of the popup.
  -- @param height number The height of the popup.
  scratch.open_buffer = function(filetype, width, height)
    -- Calculate popup dimensions based on the window size and config defaults.
    local win_width = vim.o.columns
    local win_height = vim.o.lines

    local popup_width = width or math.floor(win_width * config.default_width)
    local popup_height = height or math.floor(win_height * config.default_height)

    -- Create a new buffer for the popup.
    local bufnr = vim.api.nvim_create_buf(false, true)

    -- Set filetype for the buffer if specified.
    if filetype then vim.api.nvim_buf_set_option(bufnr, 'filetype', filetype) end

    -- Import `Popup` class from `nui.popup`.
    local Popup = require('nui.popup')

    -- If popup already exists, restore its state and show it.
    if popup and vim.api.nvim_buf_is_loaded(bufnr) then
      restore_buffer_state(bufnr)
      popup:show()
      return
    end

    -- Create a new popup with specified configurations.
    local popup = Popup({
      enter = true,
      focusable = true,
      -- Define border and window options.
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
      -- Set size and position based on calculated dimensions and config.
      size = {
        width = popup_width,
        height = popup_height,
      },
      position = {
        row = config.position.row,
        col = config.position.col,
      },
    })

    -- Set the border highlight.
    popup.border:set_highlight('Normal')

    -- Register events for saving and restoring buffer state.
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

    -- Mount the popup window.
    popup:mount()
  end
end

-- Return the configured `scratch` table.
return scratch
