return {
  -- Mason (LSP installer)
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    cmd = "Mason",
    opts = {},
  },

  -- Mason LSP config
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
        "pyright",
        "tsserver",
        "html",
        "cssls",
        "jsonls",
        "clangd",
        "gopls",
      },
    },
  },

  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Lua
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
            telemetry = { enable = false },
          },
        },
      })

      -- Python
      lspconfig.pyright.setup({ capabilities = capabilities })

      -- C / C++
      lspconfig.clangd.setup({
        capabilities = capabilities,
      })

      -- C#
      lspconfig.roslyn_lsp = {} -- handled by roslyn.nvim plugin later

      -- JS/TS, HTML, CSS, JSON
      lspconfig.tsserver.setup({ capabilities = capabilities })
      lspconfig.html.setup({ capabilities = capabilities })
      lspconfig.cssls.setup({ capabilities = capabilities })
      lspconfig.jsonls.setup({ capabilities = capabilities })

      lspconfig.gdscript.setup({
        capabilities = capabilities,
      })

      -- Keymaps (common for all LSPs)
      local opts = { noremap = true, silent = true }
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
    end,
  },

  -- C# formatting with Roslyn
  {
    "seblj/roslyn.nvim",
    ft = "cs",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local roslyn = require("roslyn")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      roslyn.setup({
        capabilities = capabilities,
        filetypes = { "cs" },
        on_attach = function(client, bufnr)
          -- Enable formatting
          client.server_capabilities.documentFormattingProvider = true
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ async = false })
            end,
          })
        end,
      })
    end,
  },

  -- -- Conform.nvim (general formatter)
  -- {
  --   "stevearc/conform.nvim",
  --   event = "BufReadPre",
  --   config = function()
  --     require("conform").setup({
  --       formatters_by_ft = {
  --         lua = { "stylua" },
  --         javascript = { "prettier" },
  --         typescript = { "prettier" },
  --         html = { "prettier" },
  --         css = { "prettier" },
  --         scss = { "prettier" },
  --         json = { "prettier" },
  --       },
  --     })
  --
  --     -- Auto-format on save for all files EXCEPT C#
  --     vim.api.nvim_create_autocmd("BufWritePre", {
  --       callback = function()
  --         if vim.bo.filetype ~= "cs" then
  --           require("conform").format({ async = false })
  --         end
  --       end,
  --     })
  --   end,
  -- },
}
