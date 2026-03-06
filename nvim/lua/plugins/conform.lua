return {
  {
    "stevearc/conform.nvim",
    -- opts will be merged with LazyVim's defaults
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
        -- No "cs" here, so it falls back to Roslyn automatically!
      },
    },
  },
}
