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

          -- Moved this inside the function where it belongs
          return " " .. variable.value
        end,
      })

      ------------------------------------------------------------------------
      -- Signs
      ------------------------------------------------------------------------

      vim.fn.sign_define("DapBreakpoint", {
        text = "●",
        texthl = "DiagnosticError",
      })

      vim.fn.sign_define("DapBreakpointCondition", {
        text = "◆",
        texthl = "DiagnosticWarn",
      })

      vim.fn.sign_define("DapLogPoint", {
        text = "◇",
        texthl = "DiagnosticInfo",
      })

      vim.fn.sign_define("DapStopped", {
        text = "▶",
        texthl = "DiagnosticHint",
        linehl = "Visual",
        numhl = "",
      })

      vim.fn.sign_define("DapBreakpointRejected", {
        text = "✖",
        texthl = "DiagnosticWarn",
      })

      ------------------------------------------------------------------------
      -- C# / .NET
      ------------------------------------------------------------------------

      -- Prefer netcoredbg from PATH (Mason adds its bin dir once mason.setup()
      -- has run), otherwise fall back to the Mason package location.
      local netcoredbg = vim.fn.exepath("netcoredbg")
      if netcoredbg == "" then
        netcoredbg = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg/netcoredbg"
      end

      dap.adapters.coreclr = {
        type = "executable",
        command = netcoredbg,
        args = { "--interpreter=vscode" },
      }

      -- Builds the project, then finds the dll to debug.
      -- Walk up from the current file to find the .csproj (then .sln).
      -- Falls back to nvim's cwd if the buffer isn't inside a project.
      local function project_root()
        local root = vim.fs.root(0, function(name)
          return name:match("%.csproj$") ~= nil
        end) or vim.fs.root(0, function(name)
          return name:match("%.sln$") ~= nil
        end)
        return root or vim.fn.getcwd()
      end

      local function build_and_pick_dll()
        local root = project_root()
        vim.notify("Building in " .. root .. " ...", vim.log.levels.INFO)

        local res = vim.system({ "dotnet", "build", "-c", "Debug" }, { cwd = root, text = true }):wait()
        if res.code ~= 0 then
          vim.notify((res.stdout or "") .. (res.stderr or ""), vim.log.levels.ERROR)
          return dap.ABORT
        end

        local dlls = vim.fn.glob(root .. "/bin/Debug/**/*.dll", false, true)

        -- Prefer the dll named after the .csproj in the root
        local csproj = vim.fn.glob(root .. "/*.csproj", false, true)[1]
        if csproj then
          local name = vim.fn.fnamemodify(csproj, ":t:r") .. ".dll"
          local matches = vim.tbl_filter(function(p)
            return vim.fn.fnamemodify(p, ":t") == name
          end, dlls)
          if #matches == 1 then
            return matches[1]
          end
        end

        -- Ambiguous or not found: ask
        return vim.fn.input("Path to dll: ", root .. "/bin/Debug/", "file")
      end

      -- Path to your Godot Mono/.NET executable.
      -- Set $GODOT in your shell, or edit the fallback below.
      local godot_bin = vim.env.GODOT
      if not godot_bin or godot_bin == "" then
        godot_bin = vim.fn.exepath("godot")
      end
      if godot_bin == "" then
        godot_bin = "/path/to/Godot_v4.x_mono" -- <-- change me
      end

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch .NET",
          request = "launch",
          program = build_and_pick_dll,
          cwd = project_root,
          stopAtEntry = false,
        },
        {
          type = "coreclr",
          name = "Attach to process",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
        {
          type = "coreclr",
          name = "Launch Godot",
          request = "launch",
          program = godot_bin,
          args = { "--path", "${workspaceFolder}" },
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
        },
        {
          type = "coreclr",
          name = "Attach to Godot",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
      }

      ------------------------------------------------------------------------
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

      vim.keymap.set("n", "<leader>dq", function()
        local dap = require("dap")
        -- Force the adapter to kill the application process
        dap.disconnect({ terminateDebuggee = true })
        dap.terminate()
        dap.close()
        print("Debugger terminated and process killed")
      end, { desc = "DAP: Terminate and Kill" })

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

      -- Note: netcoredbg does not support step back (works for some other adapters)
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
      vim.keymap.set({ "n", "v" }, "K", function()
        if require("dap").session() then
          dapui.eval(nil, { width = 60, height = 15, enter = false })
        else
          vim.lsp.buf.hover()
        end
      end, { desc = "Hover (DAP value when debugging, LSP otherwise)" })

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
