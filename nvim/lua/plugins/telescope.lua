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
    "*.sln",
    "*.csproj",
    "global.json",
    "Directory.Build.props",

    -- Python
    "pyproject.toml",
    "setup.py",
    "poetry.lock",
    "Pipfile",
    "requirements.txt",

    -- Other common markers
    "package.json",
    "Cargo.toml",
    "go.mod",
    "pom.xml",
    "composer.json",
    "Gemfile",
    "CMakeLists.txt",
    ".root",
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

  -- First try priority markers (.git, .hg, .svn)
  local root = search_upwards(current_dir, priority_markers)

  -- If not found, try language-specific project files
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
      -- ============================================================
      -- FILE FINDING
      -- ============================================================

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

      -- Main file finder: Find files in project root
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

      -- ============================================================
      -- TEXT SEARCHING
      -- ============================================================

      -- Live grep in project
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

      -- Search word under cursor
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

      -- Search in current file only
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

      -- ============================================================
      -- ADDITIONAL PICKERS
      -- ============================================================

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

      -- Git files
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
          -- ==========================================================
          -- RIPGREP ARGUMENTS
          -- ==========================================================

          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",

            -- Exclude directories
            "--glob=!.git/",
            "--glob=!__pycache__/",
            "--glob=!*.pyc",
            "--glob=!bin/",
            "--glob=!obj/",
            "--glob=!node_modules/",
          },

          -- ==========================================================
          -- UI CONFIGURATION
          -- ==========================================================

          prompt_prefix = " 󰼛 ",
          selection_caret = " ",
          entry_prefix = "   ",

          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "ascending",

          -- ==========================================================
          -- LAYOUT
          -- ==========================================================

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

          -- ==========================================================
          -- FILE IGNORE PATTERNS
          -- ==========================================================

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

            -- Media
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

          -- ==========================================================
          -- DISPLAY
          -- ==========================================================

          path_display = { "truncate" },
          winblend = 0,

          border = {},

          borderchars = {
            "─",
            "│",
            "─",
            "│",
            "╭",
            "╮",
            "╯",
            "╰",
          },

          color_devicons = true,

          set_env = {
            ["COLORTERM"] = "truecolor",
          },

          -- ==========================================================
          -- KEY MAPPINGS
          -- ==========================================================

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

        -- ============================================================
        -- PICKERS
        -- ============================================================

        pickers = {
          find_files = {
            hidden = false,
            follow = true,
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
                ["<C-d>"] = "delete_buffer",
              },

              n = {
                ["dd"] = "delete_buffer",
              },
            },
          },
        },

        -- ============================================================
        -- EXTENSIONS
        -- ============================================================

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

            ignore_patterns = {
              "*.git/*",
              "*/tmp/*",
              "*/__pycache__/*",
            },
          },
        },
      })

      -- ============================================================
      -- LOAD EXTENSIONS
      -- ============================================================

      telescope.load_extension("fzf")
      telescope.load_extension("frecency")
    end,
  },
}
