return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "leoluz/nvim-dap-go",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "mason-org/mason.nvim",
    },
    config = function()
      local dap = require("dap")
      local ui = require("dapui")

      require("dapui").setup()
      require("dap-go").setup()

      require("nvim-dap-virtual-text").setup({
        display_callback = function(variable)
          local name = string.lower(variable.name)
          local value = string.lower(variable.value)
          if name:match("secret") or name:match("api") or value:match("secret") or value:match("api") then
            return "*****"
          end
          if #variable.value > 15 then
            return " " .. string.sub(variable.value, 1, 15) .. "... "
          end
          return " " .. variable.value
        end,
      })

      -- 1. C# Configuration
      dap.adapters.coreclr = {
        type = "executable",
        command = "netcoredbg",
        args = { "--interpreter=vscode" },
      }
      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch .NET",
          request = "launch",
          program = function()
            return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
        },
      }

      -- 2. Elixir Configuration
      local elixir_ls_debugger = vim.fn.exepath("elixir-ls-debugger")
      if elixir_ls_debugger ~= "" then
        dap.adapters.mix_task = {
          type = "executable",
          command = elixir_ls_debugger,
        }
        dap.configurations.elixir = {
          {
            type = "mix_task",
            name = "phoenix server",
            task = "phx.server",
            request = "launch",
            projectDir = "${workspaceFolder}",
            exitAfterTaskReturns = false,
            debugAutoInterpretAllModules = false,
          },
        }
      end

      -- === KEYMAPS (Refactored to <leader>D) ===

      -- Breakpoints
      vim.keymap.set("n", "<leader>Db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })

      -- Execution
      vim.keymap.set("n", "<leader>Dc", dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<leader>DC", dap.run_to_cursor, { desc = "Debug: Run to Cursor" })

      -- Stepping
      vim.keymap.set("n", "<leader>Di", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<leader>Do", dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<leader>Du", dap.step_out, { desc = "Debug: Step Out" }) -- u for Up/Out
      vim.keymap.set("n", "<leader>Dp", dap.step_back, { desc = "Debug: Step Back" }) -- p for Previous

      -- Management
      vim.keymap.set("n", "<leader>Dr", dap.restart, { desc = "Debug: Restart" })
      vim.keymap.set("n", "<leader>Dq", dap.terminate, { desc = "Debug: Terminate" })

      -- UI / Eval
      vim.keymap.set("n", "<leader>Dt", ui.toggle, { desc = "Debug: Toggle UI" })
      vim.keymap.set("n", "<leader>D?", function()
        require("dapui").eval(nil, { enter = true })
      end, { desc = "Debug: Eval var under cursor" })

      -- Listeners
      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end
    end,
  },
}
