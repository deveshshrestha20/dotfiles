return {
  -- Treesitter core
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects", -- textobjects
    },
    config = function()
      local status_ok, ts_configs = pcall(require, "nvim-treesitter.configs")
      if not status_ok then
        return
      end
      ts_configs.setup({
        ensure_installed = {
          "c_sharp",
          "lua",
          "python",
          "javascript",
          "typescript",
          "html",
          "css",
          "sql",
          "go",
          "rust",
          "java",
          "markdown",
        },
        highlight = { enable = true },
        indent = { enable = true },
        sync_install = false,
        auto_install = true,
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
            },
          },
        },
      })
    end,
  },
  -- Playground plugin (removed - deprecated and incompatible)
  -- Use :InspectTree instead (built-in to Neovim 0.9+)
}
