return {
  "SmiteshP/nvim-navic",
  dependencies = { "neovim/nvim-lspconfig" },
  opts = {
    highlight = true,
    separator = "  ",
    depth_limit = 5,
    icons = require("lazyvim.config").icons.kinds,
  },
}
