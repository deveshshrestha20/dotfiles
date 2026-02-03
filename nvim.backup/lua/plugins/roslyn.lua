return {
  "seblj/roslyn.nvim",
  enabled = true,
  ft = "cs",
  config = function()
    local roslyn = require("roslyn")

    -- Setup Roslyn LSP via the plugin
    roslyn.setup({
      on_attach = function(client, bufnr)
        print("Roslyn LSP attached!")

        -- ENABLE formatting capabilities
        client.server_capabilities.documentFormattingProvider = true
        client.server_capabilities.documentRangeFormattingProvider = true

        -- Helper function for setting keymaps
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, {
            buffer = bufnr,
            noremap = true,
            silent = true,
            desc = desc,
          })
        end

        -- Add manual format keymap
        map("n", "<leader>cf", vim.lsp.buf.format, "Format document")
        map("v", "<leader>cf", vim.lsp.buf.format, "Format selection")

        -- ============================================================================
        -- CODE ACTIONS & REFACTORING
        -- ============================================================================

        -- Code actions (like auto-import, quick fixes)
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code actions")
        map("v", "<leader>ca", vim.lsp.buf.code_action, "Code actions (selection)")

        -- Remove unused imports
        map("n", "<leader>ru", function()
          vim.lsp.buf.code_action({
            context = {
              only = { "source.removeUnusedImports" },
              diagnostics = {},
            },
            apply = true,
          })
        end, "Remove unused imports")

        -- ============================================================================
        -- NAVIGATION
        -- ============================================================================

        -- Go to definition
        map("n", "gd", vim.lsp.buf.definition, "Go to definition")

        -- Go to declaration
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")

        -- Go to implementation
        map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")

        -- Go to type definition
        map("n", "gt", vim.lsp.buf.type_definition, "Go to type definition")

        -- Show references
        map("n", "gr", vim.lsp.buf.references, "Show references")
        map("n", "<leader>gr", vim.lsp.buf.references, "Show references")

        -- ============================================================================
        -- DOCUMENTATION & DIAGNOSTICS
        -- ============================================================================

        -- Hover documentation
        map("n", "K", vim.lsp.buf.hover, "Hover documentation")

        -- Signature help
        map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
        map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")

        -- Show all diagnostics in quickfix
        map("n", "<leader>q", vim.diagnostic.setqflist, "Diagnostics to quickfix")

        -- ============================================================================
        -- REFACTORING
        -- ============================================================================

        -- Rename symbol
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")

        -- Workspace symbol search
        map("n", "<leader>ws", vim.lsp.buf.workspace_symbol, "Workspace symbols")

        -- Document symbols
        map("n", "<leader>ds", vim.lsp.buf.document_symbol, "Document symbols")

        -- ============================================================================
        -- INLAY HINTS TOGGLE
        -- ============================================================================

        if client.server_capabilities.inlayHintProvider then
          map("n", "<leader>ih", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, "Toggle inlay hints")
        end
      end,

      -- ============================================================================
      -- ROSLYN-SPECIFIC SETTINGS
      -- ============================================================================

      settings = {
        -- Enable completion items from unimported namespaces
        ["csharp|completion"] = {
          dotnet_show_completion_items_from_unimported_namespaces = true,
          dotnet_show_name_completion_suggestions = true,
        },

        -- Inlay hints configuration
        ["csharp|inlay_hints"] = {
          csharp_enable_inlay_hints_for_implicit_object_creation = true,
          csharp_enable_inlay_hints_for_implicit_variable_types = true,
          csharp_enable_inlay_hints_for_lambda_parameter_types = true,
          csharp_enable_inlay_hints_for_types = true,
          dotnet_enable_inlay_hints_for_indexer_parameters = true,
          dotnet_enable_inlay_hints_for_literal_parameters = true,
          dotnet_enable_inlay_hints_for_object_creation_parameters = true,
          dotnet_enable_inlay_hints_for_other_parameters = true,
          dotnet_enable_inlay_hints_for_parameters = true,
          dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
          dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
          dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
        },

        -- Code lens (show references above methods/classes)
        ["csharp|code_lens"] = {
          dotnet_enable_references_code_lens = true,
          dotnet_enable_tests_code_lens = true,
        },

        -- Background analysis scope
        ["csharp|background_analysis"] = {
          dotnet_analyzer_diagnostics_scope = "fullSolution",
          dotnet_compiler_diagnostics_scope = "fullSolution",
        },

        -- Symbol search
        ["csharp|symbol_search"] = {
          dotnet_search_reference_assemblies = true,
        },
      },

      filetypes = { "cs" },
      capabilities = vim.lsp.protocol.make_client_capabilities(),
    })

    -- ============================================================================
    -- AUTO-FORMAT ON SAVE
    -- ============================================================================

    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.cs",
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })

    -- ============================================================================
    -- AUTO-REFRESH DIAGNOSTICS
    -- ============================================================================

    -- Refresh diagnostics automatically on InsertLeave
    vim.api.nvim_create_autocmd({ "InsertLeave" }, {
      pattern = "*.cs",
      callback = function()
        local clients = vim.lsp.get_clients({ name = "roslyn" })
        if not clients or #clients == 0 then
          return
        end
        local buffers = vim.lsp.get_buffers_by_client_id(clients[1].id)
        for _, buf in ipairs(buffers) do
          vim.lsp.util._refresh("textDocument/diagnostic", { bufnr = buf })
        end
      end,
    })
  end,
}
