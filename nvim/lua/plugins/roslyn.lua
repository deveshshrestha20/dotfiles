return {
  "seblj/roslyn.nvim",
  enabled = true,
  ft = "cs",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local roslyn = require("roslyn")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    roslyn.setup({

      cmd = { "roslyn-language-server", "--stdio" },

      capabilities = capabilities,
      on_attach = function(client, bufnr)
        print("Roslyn LSP attached!")
        -- Formatting
        client.server_capabilities.documentFormattingProvider = true
        client.server_capabilities.documentRangeFormattingProvider = true

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, {
            buffer = bufnr,
            noremap = true,
            silent = true,
            desc = desc,
          })
        end

        -- KEYMAPS
        map("n", "<leader>cf", vim.lsp.buf.format, "Format document")
        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "gr", vim.lsp.buf.references, "Show references")
        map("n", "K", vim.lsp.buf.hover, "Hover documentation")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code actions")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")

        if client.server_capabilities.inlayHintProvider then
          map("n", "<leader>ih", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, "Toggle inlay hints")
        end
      end,
      settings = {
        ["csharp|completion"] = {
          dotnet_show_completion_items_from_unimported_namespaces = true,
          dotnet_show_name_completion_suggestions = true,
        },
        ["csharp|inlay_hints"] = {
          csharp_enable_inlay_hints_for_implicit_object_creation = true,
          csharp_enable_inlay_hints_for_implicit_variable_types = true,
          csharp_enable_inlay_hints_for_types = true,
        },
        ["csharp|background_analysis"] = {
          dotnet_analyzer_diagnostics_scope = "fullSolution",
          dotnet_compiler_diagnostics_scope = "fullSolution",
        },
      },
      filetypes = { "cs" },
    })

    -- Auto-format on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.cs",
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
}
