-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Open terminal in current file directory (floating) - TOGGLETERM
vim.keymap.set("n", "<leader>fT", function()
  local Terminal = require("toggleterm.terminal").Terminal
  Terminal:new({
    dir = vim.fn.expand("%:p:h"), -- current file's directory
    direction = "float",
    hidden = true,
  }):toggle()
end, { desc = "Terminal (current file dir)" })

-- -- Open terminal at bottom - TOGGLETERM
-- vim.keymap.set("n", "<leader>tt", function()
--   local ok, toggleterm = pcall(require, "toggleterm.terminal")
--   if not ok then
--     vim.notify("toggleterm.nvim not found", vim.log.levels.ERROR)
--     return
--   end
--   toggleterm.Terminal
--     :new({
--       dir = vim.fn.expand("%:p:h"), -- current file's directory
--       direction = "horizontal", -- open at bottom
--       hidden = true,
--     })
--     :toggle()
-- end, { desc = "Terminal (bottom, current file dir)" })
--

-- Toggle tmux popup terminal (<leader>tt) - TMUX
vim.keymap.set("n", "<leader>tt", function()
  local current_dir = vim.fn.expand("%:p:h")
  vim.fn.system(
    string.format("tmux display-popup -E -w 80%% -h 80%% 'tmux new-session -A -s popup-term -c \"%s\"'", current_dir)
  )
end, { desc = "Toggle popup terminal" })

-- Exit terminal mode with Ctrl+t and go to normal mode
vim.keymap.set("t", "<C-t>", [[<C-\><C-n>]], { desc = "Exit terminal to normal mode" })

-- Select all text (Ctrl + A)
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select all text" })

-- Floating terminal at root directory - TOGGLETERM
vim.keymap.set("n", "<leader>rt", function()
  local Terminal = require("toggleterm.terminal").Terminal
  Terminal:new({
    dir = "/", -- absolute root directory
    direction = "float",
    hidden = true,
    float_opts = {
      width = math.floor(vim.o.columns * 0.8),
      height = math.floor(vim.o.lines * 0.6),
      border = "rounded",
    },
  }):toggle()
end, { desc = "Floating Terminal (system root)" })

-- Unmap LazyVim default Terminal (Root Dir)
vim.keymap.set("n", "<leader>ft", "<Nop>", { desc = "Disabled LazyVim Terminal keymap" })

-- Disable LazyVim leader-c keymaps
vim.keymap.set("n", "<leader>c", "<Nop>")

-- Change to Terminal from buffer (<leader>ct)
vim.keymap.set("n", "<leader>ct", function()
  -- Loop through all windows in the current tab to find a terminal
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    if ft == "toggleterm" then
      vim.api.nvim_set_current_win(win) -- Move cursor to terminal
      vim.api.nvim_feedkeys("i", "n", false) -- Enter terminal mode
      return
    end
  end
  vim.notify("No terminal found!", vim.log.levels.WARN)
end, { desc = "Change to terminal" })

-- Change to Buffer from terminal (Ctrl+b)
vim.keymap.set("t", "<C-b>", function()
  -- Exit terminal mode first
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", true)
  -- Find first real buffer (not terminal, not neo-tree, not empty)
  vim.schedule(function()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if ft ~= "toggleterm" and ft ~= "neo-tree" and buf_name ~= "" then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
    vim.notify("No buffer found!", vim.log.levels.WARN)
  end)
end, { desc = "Change to buffer" })

-- Create tmux pane at bottom (25% height) (<leader>tv) - TMUX
vim.keymap.set("n", "<leader>tv", function()
  local current_dir = vim.fn.expand("%:p:h")
  vim.fn.system(string.format("tmux split-window -v -l 25%% -c '%s' /bin/zsh", current_dir))
end, { desc = "Tmux split (bottom 25%%)" })

-- Create tmux pane at right (25% width) (<leader>th) - TMUX
vim.keymap.set("n", "<leader>th", function()
  local current_dir = vim.fn.expand("%:p:h")
  vim.fn.system(string.format("tmux split-window -h -l 25%% -c '%s' /bin/zsh", current_dir))
end, { desc = "Tmux split (right 25%%)" })

-- Vertical split: current file moves to new split, switch to another buffer in original
vim.keymap.set("n", "<leader>sv", function()
  local current_buf = vim.api.nvim_get_current_buf()
  vim.cmd("vsplit")
  vim.cmd("wincmd h") -- Move to left window
  vim.cmd("bprevious") -- Switch to previous buffer
  -- If we're back to the same buffer, try next buffer
  if vim.api.nvim_get_current_buf() == current_buf then
    vim.cmd("bnext")
  end
  vim.cmd("wincmd l") -- Move back to right window
end, { desc = "Split vertical (switch buffer)" })

-- Horizontal split: current file moves to new split, switch to another buffer in original
vim.keymap.set("n", "<leader>sh", function()
  local current_buf = vim.api.nvim_get_current_buf()
  vim.cmd("split")
  vim.cmd("wincmd k") -- Move to top window
  vim.cmd("bprevious") -- Switch to previous buffer
  -- If we're back to the same buffer, try next buffer
  if vim.api.nvim_get_current_buf() == current_buf then
    vim.cmd("bnext")
  end
  vim.cmd("wincmd j") -- Move back to bottom window
end, { desc = "Split horizontal (switch buffer)" })

-- Close current split
vim.keymap.set("n", "<leader>sc", "<cmd>close<cr>", { desc = "Close split" })

local obsidian_plugin = "obsidian.nvim"
