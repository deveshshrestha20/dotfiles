return {
  "mikavilpas/yazi.nvim",
  lazy = false,
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("yazi").setup({
      open_for_directories = true,
      show_hidden = true,
      floating_window = true, -- make Yazi open as a floating window
      floating_window_scaling_factor = 0.8, -- (optional) adjust window size
      previewer_scaling_factor = 0.7, -- scale images inside the floating window
      image_preview_alignment = "center", -- center images in the preview
      keymaps = {
        show_help = "<f1>",
      },
    })

    -- Keymap to open Yazi in current directory
    vim.keymap.set("n", "<leader>e", function()
      require("yazi").yazi()
    end, { desc = "Open Yazi file manager" })

    -- Keymap to open Yazi in home directory (Downloads, Documents, etc.)
    vim.keymap.set("n", "<leader>E", function()
      require("yazi").yazi(nil, vim.fn.expand("~"))
    end, { desc = "Open Yazi in home directory" })

    -- Optional: Open Yazi in the project root (git root or cwd)
    vim.keymap.set("n", "<leader>fe", function()
      require("yazi").yazi(nil, vim.fn.getcwd())
    end, { desc = "Open Yazi in project root" })
  end,
}
