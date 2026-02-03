return {
  -- Core database plugin
  {
    "tpope/vim-dadbod",
  },

  -- Database UI
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    init = function()
      -- Use nerd fonts for icons
      vim.g.db_ui_use_nerd_fonts = 1
      -- Location to save saved queries
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
      -- Optional: Automatically open UI after running queries
      vim.g.db_ui_auto_execute_table_helpers = 1
    end,
    keys = {
      -- Open Dadbod UI
      { "<leader>du", ":DBUI<CR>", desc = "Open Dadbod UI" },
      -- Toggle Dadbod UI
      { "<leader>dq", ":DBUIToggle<CR>", desc = "Toggle Dadbod UI" },
      -- Add a new database connection
      { "<leader>da", ":DBUIAddConnection<CR>", desc = "Add DB Connection" },
    },
  },

  -- SQL autocompletion
  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = { "tpope/vim-dadbod" },
    config = function()
      -- Optional: Only enable for SQL filetypes
      vim.cmd([[
        autocmd FileType sql lua require('cmp').setup.buffer({ sources = { { name = 'vim-dadbod-completion' } } })
      ]])
    end,
  },

  -- Keymaps for executing SQL queries
  {
    "tpope/vim-dadbod",
    config = function()
      -- Execute the whole buffer
      vim.keymap.set("n", "<leader>de", ":%DB<CR>", { desc = "Execute whole buffer" })

      -- Execute the current line (Normal mode)
      vim.keymap.set("n", "<leader>dl", ":.DB<CR>", { desc = "Execute current line" })

      -- Execute visual selection (Visual mode)
      vim.keymap.set("v", "<leader>de", ":DB<CR>", { desc = "Execute selection" })
    end,
  },
}
