require("custom.keymaps")
vim.defer_fn(function()
  vim.cmd("wincmd =")
end, 100)
