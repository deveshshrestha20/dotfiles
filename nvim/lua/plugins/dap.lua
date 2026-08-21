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
      local dapui = require("dapui")
      local widgets = require("dap.ui.widgets")

      ------------------------------------------------------------------------
      -- Plugins
      ------------------------------------------------------------------------
      dapui.setup()
      require("dap-go").setup()

      require("nvim-dap-virtual-text").setup({
        display_callback = function(variable)
          local name = variable.name:lower()
          local value = variable.value:lower()

          if name:match("secret") or name:match("api") or value:match("secret") or value:match("api") then
            return " *****"
          end

          if #variable.value > 30 then
            return " " .. variable.value:sub(1, 30) .. "..."
          end

          return " " .. variable.value
        end,
      })

      ------------------------------------------------------------------------
      -- Signs
      ------------------------------------------------------------------------

      vim.fn.sign_define("DapBreakpoint", {
        text = "",
        texthl = "DiagnosticError",
      })

      vim.fn.sign_define("DapBreakpointCondition", {
        text = "",
        texthl = "DiagnosticWarn",
      })

      vim.fn.sign_define("DapLogPoint", {
        text = "󰆏",
        texthl = "DiagnosticInfo",
      })

      vim.fn.sign_define("DapStopped", {
        text = "",
        texthl = "DiagnosticHint",
        linehl = "Visual",
        numhl = "",
      })

      vim.fn.sign_define("DapBreakpointRejected", {
        text = "",
        texthl = "DiagnosticWarn",
      })

      ----------------------------------------------------------------------
      -- C#
      ----------------------------------------------------------------------

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
        {
          type = "coreclr",
          name = "Attach to Godot",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
      } ------------------------------------------------------------------------
      -- Elixir
      ------------------------------------------------------------------------

      local elixir_ls_debugger = vim.fn.exepath("elixir-ls-debugger")

      if elixir_ls_debugger ~= "" then
        dap.adapters.mix_task = {
          type = "executable",
          command = elixir_ls_debugger,
        }

        dap.configurations.elixir = {
          {
            type = "mix_task",
            name = "Phoenix Server",
            task = "phx.server",
            request = "launch",
            projectDir = "${workspaceFolder}",
            exitAfterTaskReturns = false,
            debugAutoInterpretAllModules = false,
          },
        }
      end

      ------------------------------------------------------------------------
      -- Keymaps
      ------------------------------------------------------------------------

      -- Breakpoints
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, {
        desc = "DAP: Toggle Breakpoint",
      })

      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, {
        desc = "DAP: Conditional Breakpoint",
      })

      vim.keymap.set("n", "<leader>dg", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log point: "))
      end, {
        desc = "DAP: Log Point",
      })

      -- Execution
      vim.keymap.set("n", "<leader>dc", dap.continue, {
        desc = "DAP: Continue",
      })

      vim.keymap.set("n", "<leader>dr", function()
        dap.terminate()
        dap.run_last()
      end, {
        desc = "DAP: Restart",
      })

      vim.keymap.set("n", "<leader>dl", dap.run_last, {
        desc = "DAP: Run Last",
      })

      vim.keymap.set("n", "<leader>dq", dap.terminate, {
        desc = "DAP: Terminate",
      })

      vim.keymap.set("n", "<leader>dC", dap.run_to_cursor, {
        desc = "DAP: Run to Cursor",
      })

      -- Stepping
      vim.keymap.set("n", "<leader>di", dap.step_into, {
        desc = "DAP: Step Into",
      })

      vim.keymap.set("n", "<leader>do", dap.step_over, {
        desc = "DAP: Step Over",
      })

      vim.keymap.set("n", "<leader>dO", dap.step_out, {
        desc = "DAP: Step Out",
      })

      vim.keymap.set("n", "<leader>dp", dap.step_back, {
        desc = "DAP: Step Back",
      })

      -- UI
      vim.keymap.set("n", "<leader>du", dapui.toggle, {
        desc = "DAP: Toggle UI",
      })

      vim.keymap.set({ "n", "v" }, "<leader>de", function()
        dapui.eval()
      end, {
        desc = "DAP: Evaluate",
      })

      vim.keymap.set("n", "<leader>ds", dap.repl.open, {
        desc = "DAP: Open REPL",
      })

      -- Widgets
      vim.keymap.set("n", "<leader>dh", widgets.hover, {
        desc = "DAP: Hover Variable",
      })

      vim.keymap.set("n", "<leader>df", widgets.centered_float, {
        desc = "DAP: Floating Scopes",
      })

      ------------------------------------------------------------------------
      -- Vimdow / Godot
      ------------------------------------------------------------------------

      vim.keymap.set("n", "<leader>dt", function()
        vim.cmd("VimdowToggleBreakpoint")
      end, {
        desc = "Godot: Toggle Breakpoint",
      })

      ------------------------------------------------------------------------
      -- DAP UI Listeners
      ------------------------------------------------------------------------

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end

      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end

      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
}
