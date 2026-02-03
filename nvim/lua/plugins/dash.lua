return {
  "snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        pick = function(cmd, opts)
          return lazyvim.pick(cmd, opts)()
        end,
        header = [[













 


     ███████╗ ████████╗ █████╗    ██████╗  ████████╗
     ██╔════╝ ╚══██╔══╝ ██╔══██╗  ██╔══██╗ ╚══██╔══╝
     ███████╗    ██║    ███████║  ██████╔╝    ██║   
     ╚════██║    ██║    ██╔══██║  ██╔══██╗    ██║   
     ███████║    ██║    ██║  ██║  ██║  ██║    ██║   
   ╚══════╝    ╚═╝    ╚═╝  ╚═╝  ╚═╝  ╚═╝    ╚═╝ 

 ]],
        -- stylua: ignore
        ---@type snacks.dashboard.item[]
        keys = {
          { icon = " ", key = "n", desc = "new file", action = ":ene | startinsert" },
          { icon = " ", key = "s", desc = "restore session", section = "session" },
          { icon = " ", key = "q", desc = "quit", action = ":qa" },
        }
,
      },
    },
  },
}
