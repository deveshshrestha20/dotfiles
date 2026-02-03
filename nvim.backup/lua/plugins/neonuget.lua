return {
  "MonsieurTib/neonuget",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  ft = { "cs", "csproj", "sln", "fsproj", "vbproj" },
  keys = {
    { "<leader>ni", "<cmd>NuGet<cr>", desc = "NuGet Package Manager" },
  },
  config = function()
    require("neonuget").setup({
      dotnet_path = "dotnet",
      default_project = nil,
    })
  end,
}
