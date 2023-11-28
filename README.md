
# Neovim Scratch Buffer

This Lua plugin for Neovim provides a handy scratch buffer functionality, allowing you to quickly open, edit, and close a temporary buffer without losing its contents or position. The buffer content and cursor position are preserved across sessions, making it ideal for jotting down notes, temporary edits, or any other short-term data storage needs during your Neovim session.

## Features

- **Persistent Buffer Content**: Contents of the scratch buffer are preserved even after closing, allowing you to reopen and continue from where you left off.
- **Cursor Position Memory**: Remembers the cursor's last position in the scratch buffer, so you can pick up exactly where you left off.
- **Customizable Size and Appearance**: Configure the size and border style of the scratch buffer to suit your preferences.
- **Automatic State Management**: Automatically stores buffer content and cursor position on buffer leave, ensuring no data loss.

## Installation

To install this plugin, you can use your favorite package manager for Neovim. Here's an example using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'kyza-2k/neovim-scratch-buffer',
  requires = { 'MunifTanjim/nui.nvim' },
  opts = {
    -- configurations go here
  },
}
