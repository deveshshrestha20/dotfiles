return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        html = { "prettier" },
        css = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        rust = { "rustfmt" },
      },
    },
  },
}
