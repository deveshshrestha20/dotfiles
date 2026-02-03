-- Shared function to find project root (works for C# and Python projects)
local function find_project_root()
  -- PRIORITY 1: Version control (most reliable - stops at .git)
  local priority_markers = {
    ".git",
    ".hg",
    ".svn",
  }

  -- PRIORITY 2: Language-specific project root files
  local secondary_markers = {
    -- .NET / C#
    "*.sln", -- Visual Studio Solution (highest priority for C#)
    "*.csproj", -- C# Project file
    "global.json", -- .NET global config
    "Directory.Build.props",

    -- Python
    "pyproject.toml", -- Modern Python (PEP 518) - highest priority for Python
    "setup.py", -- Traditional Python setup
    "poetry.lock", -- Poetry projects
    "Pipfile", -- Pipenv projects
    "requirements.txt", -- Pip requirements

    -- Other common markers
    "package.json", -- JavaScript/TypeScript
    "Cargo.toml", -- Rust
    "go.mod", -- Go
    "pom.xml", -- Java Maven
    "composer.json", -- PHP
    "Gemfile", -- Ruby
    "CMakeLists.txt", -- C/C++
    ".root", -- Custom marker
  }

  local current_file = vim.fn.expand("%:p")
  local current_dir = current_file == "" and vim.fn.getcwd() or vim.fn.fnamemodify(current_file, ":h")

  local function has_marker(path, marker)
    local marker_path = path .. "/" .. marker
    if marker:match("%*") then
      local matches = vim.fn.glob(marker_path, false, true)
      return #matches > 0
    else
      return vim.fn.isdirectory(marker_path) == 1 or vim.fn.filereadable(marker_path) == 1
    end
  end

  local function search_upwards(path, markers)
    if path == "/" or path == "" or path == vim.fn.expand("~") then
      return nil
    end

    for _, marker in ipairs(markers) do
      if has_marker(path, marker) then
        return path
      end
    end

    local parent = vim.fn.fnamemodify(path, ":h")
    if parent == path then
      return nil
    end
    return search_upwards(parent, markers)
  end

  -- First try priority markers (like .git) - this will find your project root
  local root = search_upwards(current_dir, priority_markers)

  -- If not found, try secondary markers (language-specific files)
  if not root then
    root = search_upwards(current_dir, secondary_markers)
  end

  return root or vim.fn.getcwd()
end

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      "nvim-telescope/telescope-frecency.nvim",
    },
    keys = {
      -- ====== FILE FINDING ======

      -- Recent/frequent files
      {
        "<leader>fd",
        function()
          require("telescope").extensions.frecency.frecency()
        end,
        desc = "Recent/frequent files",
      },

      -- Find files in Neovim config
      {
        "<leader>wn",
        function()
          require("telescope.builtin").find_files({
            cwd = vim.fn.stdpath("config"),
            prompt_title = "Neovim Config",
          })
        end,
        desc = "Find in Neovim config",
      },

      -- MAIN FILE FINDER: Find files in project root
      {
        "<leader><leader>",
        function()
          local project_root = find_project_root()
          require("telescope.builtin").find_files({
            cwd = project_root,
            prompt_title = "Files: " .. vim.fn.fnamemodify(project_root, ":t"),
          })
        end,
        desc = "Find files in project",
      },

      -- Find all files (including hidden/ignored)
      {
        "<leader>fh",
        function()
          local project_root = find_project_root()
          require("telescope.builtin").find_files({
            cwd = project_root,
            hidden = true,
            no_ignore = true,
            prompt_title = "All Files: " .. vim.fn.fnamemodify(project_root, ":t"),
          })
        end,
        desc = "Find all files (hidden)",
      },

      -- ====== TEXT SEARCHING (GREP) ======

      -- GREP 1: Live grep in project (most important - search as you type)
      {
        "<leader>sg",
        function()
          local project_root = find_project_root()
          require("telescope.builtin").live_grep({
            cwd = project_root,
            prompt_title = "Grep: " .. vim.fn.fnamemodify(project_root, ":t"),
          })
        end,
        desc = "Search text in project",
      },

      -- GREP 2: Search word under cursor
      {
        "<leader>sw",
        function()
          local project_root = find_project_root()
          require("telescope.builtin").grep_string({
            cwd = project_root,
            prompt_title = "Find: " .. vim.fn.expand("<cword>"),
          })
        end,
        desc = "Search word under cursor",
      },

      -- GREP 3: Search in current file only
      {
        "<leader>sf",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find({
            prompt_title = "Search: " .. vim.fn.expand("%:t"),
          })
        end,
        desc = "Search in current file",
      },

      -- Resume last search
      {
        "<leader>sr",
        function()
          require("telescope.builtin").resume()
        end,
        desc = "Resume last search",
      },

      -- ====== ADDITIONAL USEFUL PICKERS ======

      -- Buffers
      {
        "<leader>fb",
        function()
          require("telescope.builtin").buffers({
            sort_mru = true,
            ignore_current_buffer = true,
          })
        end,
        desc = "Find buffers",
      },

      -- Git files (fast when in git repo)
      {
        "<leader>gf",
        function()
          require("telescope.builtin").git_files()
        end,
        desc = "Find git files",
      },

      -- Git commits
      {
        "<leader>gc",
        function()
          require("telescope.builtin").git_commits()
        end,
        desc = "Git commits",
      },

      -- Help tags
      {
        "<leader>fk",
        function()
          require("telescope.builtin").help_tags()
        end,
        desc = "Find help",
      },
    },

    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          -- Ripgrep arguments (optimized for searching)
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden", -- Search hidden files
            "--glob=!.git/", -- But exclude .git directory
            "--glob=!__pycache__/", -- Exclude Python cache
            "--glob=!*.pyc", -- Exclude Python bytecode
            "--glob=!bin/", -- Exclude .NET bin
            "--glob=!obj/", -- Exclude .NET obj
            "--glob=!node_modules/", -- Exclude node_modules
          },

          -- UI Configuration
          prompt_prefix = " 󰼛 ",
          selection_caret = " ",
          entry_prefix = "   ",
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "ascending",

          -- Layout
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.45,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },

          -- Performance - ignore these patterns
          file_ignore_patterns = {
            -- Version control
            ".git/",
            ".hg/",

            -- Python
            "__pycache__/",
            "%.pyc",
            "%.pyo",
            "%.egg-info/",
            ".pytest_cache/",
            ".mypy_cache/",
            "venv/",
            "env/",
            ".venv/",

            -- .NET / C#
            "bin/",
            "obj/",
            "%.dll",
            "%.exe",
            "%.pdb",

            -- Node
            "node_modules/",
            "package-lock.json",
            "yarn.lock",

            -- Media files
            "%.jpg",
            "%.jpeg",
            "%.png",
            "%.svg",
            "%.gif",
            "%.ico",
            "%.pdf",

            -- Fonts
            "%.otf",
            "%.ttf",
            "%.woff",
            "%.woff2",
          },

          -- Display
          path_display = { "truncate" },
          winblend = 0,
          border = {},
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          color_devicons = true,
          set_env = { ["COLORTERM"] = "truecolor" },

          -- Better key mappings
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<C-s>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-d>"] = actions.delete_buffer,
              ["<Esc>"] = actions.close,
            },
            n = {
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<C-s>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["dd"] = actions.delete_buffer,
              ["q"] = actions.close,
            },
          },
        },

        pickers = {
          find_files = {
            hidden = false,
            follow = true, -- Follow symlinks
          },
          live_grep = {
            additional_args = function()
              return { "--hidden" }
            end,
          },
          buffers = {
            show_all_buffers = true,
            sort_lastused = true,
            mappings = {
              i = {
                ["<c-d>"] = "delete_buffer",
              },
              n = {
                ["dd"] = "delete_buffer",
              },
            },
          },
        },

        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          frecency = {
            show_scores = false,
            show_unindexed = true,
            ignore_patterns = { "*.git/*", "*/tmp/*", "*/__pycache__/*" },
          },
        },
      })

      -- Load extensions
      telescope.load_extension("fzf")
      telescope.load_extension("frecency")

      -- Catppuccin theme integration
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          local has_catppuccin, catppuccin = pcall(require, "catppuccin.palettes")
          if has_catppuccin then
            local palette = catppuccin.get_palette()

            -- Elegant Monochrome theme (currently active)
            vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = palette.overlay0, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = palette.lavender, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = palette.overlay0, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = palette.overlay0, bg = "NONE" })

            vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = palette.crust, bg = palette.lavender, bold = true })
            vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { fg = palette.text, bg = palette.surface0, bold = true })
            vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { fg = palette.text, bg = palette.surface0, bold = true })

            -- Common settings
            vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = palette.base })
            vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = palette.surface0 })
            vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = palette.mantle })
            vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = palette.mantle })

            vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = palette.text, bg = palette.surface1, bold = true })
            vim.api.nvim_set_hl(0, "TelescopeSelectionCaret", { fg = palette.lavender, bg = palette.surface1 })
            vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = palette.lavender, bg = palette.surface0 })
            vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = palette.peach, bold = true })
          else
            -- Fallback if Catppuccin not available
            vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "FloatBorder" })
            vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "FloatBorder" })
            vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { link = "FloatBorder" })
            vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { link = "FloatBorder" })
          end
        end,
      })

      -- Apply theme immediately
      vim.schedule(function()
        vim.cmd("doautocmd ColorScheme")
      end)
    end,
  },
}
