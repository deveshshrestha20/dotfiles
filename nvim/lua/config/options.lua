-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_picker = "telescope"

-- Highlight groups for the winbar, linked to existing theme groups so
-- colors adapt automatically when you switch colorschemes
vim.api.nvim_set_hl(0, "WinBarFile", { link = "Title", default = true })
vim.api.nvim_set_hl(0, "WinBarModified", { link = "WarningMsg", default = true })
vim.api.nvim_set_hl(0, "WinBarReadonly", { link = "ErrorMsg", default = true })

-- Builds the winbar string for the current window
local function styled_winbar()
  local filename = vim.fn.expand("%:t")
  if filename == "" then
    return ""
  end

  local ok, devicons = pcall(require, "nvim-web-devicons")
  local icon = ""
  if ok then
    local ic = devicons.get_icon(filename, vim.fn.expand("%:e"), { default = true })
    icon = ic and (ic .. " ") or ""
  end

  local modified = vim.bo.modified and " %#WinBarModified#●%*" or ""
  local readonly = (vim.bo.readonly or not vim.bo.modifiable) and " %#WinBarReadonly#[RO]%*" or ""

  return "%#WinBarFile# " .. icon .. filename .. "%*" .. modified .. readonly
end

_G.styled_winbar = styled_winbar

-- Apply winbar only to normal file buffers (skip neo-tree, terminals, etc.)
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "BufModifiedSet" }, {
  callback = function()
    if vim.bo.buftype == "" then
      vim.opt_local.winbar = "%{%v:lua.styled_winbar()%}"
    else
      vim.opt_local.winbar = nil
    end
  end,
})
