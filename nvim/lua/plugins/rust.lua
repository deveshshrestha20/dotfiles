return {
  {
    "mrcjkb/rustaceanvim",
    version = "^9",
    lazy = false,

    init = function()
      local cfg = require("rustaceanvim.config")

      local extension_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension"

      vim.g.rustaceanvim = {
        server = {
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
              },
              check = {
                command = "clippy",
              },
            },
          },
        },

        dap = {
          adapter = cfg.get_codelldb_adapter(
            extension_path .. "/adapter/codelldb",
            extension_path .. "/lldb/lib/liblldb.so"
          ),
        },
      }
    end,
  },
}
