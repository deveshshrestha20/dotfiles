return {
  "nvzone/typr",
  dependencies = "nvzone/volt",
  keys = {
    {
      "<leader>ty",
      function()
        vim.cmd("Typr")
      end,
      desc = "Start typing practice",
    },
  },
  config = function()
    -- any additional config
  end,
}
