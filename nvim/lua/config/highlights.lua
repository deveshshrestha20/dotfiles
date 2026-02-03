-- Completion menu colors - transparent/matching your UI
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    -- Make popup menu background transparent or match your theme
    vim.api.nvim_set_hl(0, "Pmenu", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#2e3440", fg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE", fg = "#5e81ac" })
  end,
})

-- Apply immediately
vim.api.nvim_set_hl(0, "Pmenu", { bg = "#24273a", fg = "#cad3f5" })
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#363a4f", fg = "#cad3f5" })
vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#1e2030" })
vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#363a4f" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#24273a", fg = "#cad3f5" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#24273a", fg = "#8aadf4" })
