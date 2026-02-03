local opts = { noremap = true, silent = false }
vim.keymap.set("n", "<leader>r", function()
  local word = vim.fn.expand("<cword>")
  local replacement = vim.fn.input('Replace "' .. word .. '" with: ')
  if replacement ~= "" then
    local cursor_pos = vim.api.nvim_win_get_cursor(0) -- Save cursor position
    vim.cmd("%s/\\<" .. word .. "\\>/" .. replacement .. "/g")
    vim.api.nvim_win_set_cursor(0, cursor_pos) -- Restore cursor position
    print('Replaced "' .. word .. '" with "' .. replacement .. '"')
  end
end, opts)
