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
      -- Frecency: recent/frequent files
      {
        "<leader>fd",
        function()
          require("telescope").extensions.frecency.frecency()
        end,
        desc = "Find recent/frequent files",
      },

      -- Find files in Neovim config folder
      {
        "<leader>wn",
        function()
          require("telescope.builtin").find_files({
            cwd = vim.fn.stdpath("config"),
          })
        end,
        desc = "Find files in Neovim config",
      },

      -- MAIN FILE FINDER: Find files in project root
      {
        "<leader><leader>",
        function()
          local function find_project_root()
            -- Prioritized markers - checked first
            local priority_markers = {
              ".git",
              ".hg",
              ".svn",
            }

            -- Secondary markers
            local secondary_markers = {
              "*.sln",
              "*.csproj",
              "global.json",
              "pyproject.toml",
              "setup.py",
              "poetry.lock",
              "Pipfile",
              "docker-compose.yml",
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

            -- First try priority markers (like .git)
            local root = search_upwards(current_dir, priority_markers)

            -- If not found, try secondary markers
            if not root then
              root = search_upwards(current_dir, secondary_markers)
            end

            return root or vim.fn.getcwd()
          end

          local project_root = find_project_root()
          require("telescope.builtin").find_files({
            cwd = project_root,
            prompt_title = "Project: " .. vim.fn.fnamemodify(project_root, ":t"),
          })
        end,
        desc = "Find files in project root",
      },
      -- GREP 1: Search text in entire project
      {
        "<leader>sg",
        function()
          local function find_project_root()
            local root_markers = {
              ".git",
              "*.sln",
              "*.csproj",
              "global.json",
              "Directory.Build.props",
              "nuget.config",
              "Program.cs",
              ".gitignore",
              ".hg",
              ".svn",
              "*.fsproj",
              "*.vbproj",
              "main.py",
              "app.py",
              "manage.py",
              "requirements.txt",
              "setup.py",
              "pyproject.toml",
              "Pipfile",
              "poetry.lock",
              "package.json",
              "package-lock.json",
              "yarn.lock",
              "pnpm-lock.yaml",
              "node_modules",
              "tsconfig.json",
              "Cargo.toml",
              "Cargo.lock",
              "go.mod",
              "go.sum",
              "pom.xml",
              "build.gradle",
              "gradlew",
              "composer.json",
              "Gemfile",
              "Makefile",
              "CMakeLists.txt",
              ".root",
              "README.md",
            }

            local current_file = vim.fn.expand("%:p")
            local current_dir = current_file == "" and vim.fn.getcwd() or vim.fn.fnamemodify(current_file, ":h")

            local function search_upwards(path)
              if path == "/" or path == "" or path == vim.fn.expand("~") then
                return vim.fn.getcwd()
              end

              for _, marker in ipairs(root_markers) do
                local marker_path = path .. "/" .. marker
                if marker:match("%*") then
                  local matches = vim.fn.glob(marker_path, false, true)
                  if #matches > 0 then
                    return path
                  end
                else
                  if vim.fn.isdirectory(marker_path) == 1 or vim.fn.filereadable(marker_path) == 1 then
                    return path
                  end
                end
              end

              local parent = vim.fn.fnamemodify(path, ":h")
              if parent == path then
                return vim.fn.getcwd()
              end
              return search_upwards(parent)
            end

            return search_upwards(current_dir)
          end

          local project_root = find_project_root()
          require("telescope.builtin").live_grep({
            cwd = project_root,
            prompt_title = "Grep in: " .. vim.fn.fnamemodify(project_root, ":t"),
          })
        end,
        desc = "Search text in project",
      },

      -- GREP 2: Search word under cursor in project
      {
        "<leader>sw",
        function()
          local function find_project_root()
            local root_markers = {
              ".git",
              "*.sln",
              "*.csproj",
              "global.json",
              "Directory.Build.props",
              "nuget.config",
              "Program.cs",
              ".gitignore",
              ".hg",
              ".svn",
              "*.fsproj",
              "*.vbproj",
              "main.py",
              "app.py",
              "manage.py",
              "requirements.txt",
              "setup.py",
              "pyproject.toml",
              "Pipfile",
              "poetry.lock",
              "package.json",
              "package-lock.json",
              "yarn.lock",
              "pnpm-lock.yaml",
              "node_modules",
              "tsconfig.json",
              "Cargo.toml",
              "Cargo.lock",
              "go.mod",
              "go.sum",
              "pom.xml",
              "build.gradle",
              "gradlew",
              "composer.json",
              "Gemfile",
              "Makefile",
              "CMakeLists.txt",
              ".root",
              "README.md",
            }

            local current_file = vim.fn.expand("%:p")
            local current_dir = current_file == "" and vim.fn.getcwd() or vim.fn.fnamemodify(current_file, ":h")

            local function search_upwards(path)
              if path == "/" or path == "" or path == vim.fn.expand("~") then
                return vim.fn.getcwd()
              end

              for _, marker in ipairs(root_markers) do
                local marker_path = path .. "/" .. marker
                if marker:match("%*") then
                  local matches = vim.fn.glob(marker_path, false, true)
                  if #matches > 0 then
                    return path
                  end
                else
                  if vim.fn.isdirectory(marker_path) == 1 or vim.fn.filereadable(marker_path) == 1 then
                    return path
                  end
                end
              end

              local parent = vim.fn.fnamemodify(path, ":h")
              if parent == path then
                return vim.fn.getcwd()
              end
              return search_upwards(parent)
            end

            return search_upwards(current_dir)
          end

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
          require("telescope.builtin").current_buffer_fuzzy_find()
        end,
        desc = "Search in current file",
      },
    },
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
          },
          prompt_prefix = " 󰼛 ",
          selection_caret = " ",
          entry_prefix = "   ",
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "ascending",
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
          file_ignore_patterns = { "node_modules", ".git/", "%.jpg", "%.png" },
          path_display = { "truncate" },
          winblend = 0,
          border = {},
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          color_devicons = true,
          use_less = true,
          set_env = { ["COLORTERM"] = "truecolor" },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })

      -- Load extensions
      telescope.load_extension("fzf")
      telescope.load_extension("frecency")

      -- Enhanced Catppuccin theme customization
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          -- Get Catppuccin colors if available
          local has_catppuccin, catppuccin = pcall(require, "catppuccin.palettes")
          if has_catppuccin then
            local palette = catppuccin.get_palette()

            -- Option 1: Vibrant & Colorful (Current)
            -- Uncomment this block for colorful borders and titles
            --[[
            vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = palette.blue, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = palette.teal, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = palette.blue, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = palette.blue, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = palette.base, bg = palette.teal, bold = true })
            vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { fg = palette.base, bg = palette.blue, bold = true })
            vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { fg = palette.base, bg = palette.green, bold = true })
            --]]

            -- Option 2: Minimal & Clean (Subtle borders)
            -- Uncomment this block for a more minimalist look
            ----[[
            vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = palette.surface1, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = palette.surface2, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = palette.surface1, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = palette.surface1, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = palette.text, bg = palette.surface0, bold = true })
            vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { fg = palette.text, bg = palette.surface0, bold = true })
            vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { fg = palette.text, bg = palette.surface0, bold = true })
            --]]

            -- Option 3: Elegant Monochrome (Recommended)
            vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = palette.overlay0, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = palette.lavender, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = palette.overlay0, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = palette.overlay0, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = palette.crust, bg = palette.lavender, bold = true })
            vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { fg = palette.text, bg = palette.surface0, bold = true })
            vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { fg = palette.text, bg = palette.surface0, bold = true })

            -- Option 4: Accent Colors (Purple/Pink theme)
            -- Uncomment this block for purple/pink accent
            --[[
            vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = palette.mauve, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = palette.pink, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = palette.mauve, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = palette.mauve, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = palette.base, bg = palette.pink, bold = true })
            vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { fg = palette.base, bg = palette.mauve, bold = true })
            vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { fg = palette.base, bg = palette.mauve, bold = true })
            --]]

            -- Option 5: Warm Tones (Peach/Yellow)
            -- Uncomment this block for warm colors
            --[[
            vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = palette.peach, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = palette.yellow, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = palette.peach, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = palette.peach, bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = palette.base, bg = palette.yellow, bold = true })
            vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { fg = palette.base, bg = palette.peach, bold = true })
            vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { fg = palette.base, bg = palette.peach, bold = true })
            --]]

            -- Common settings for all options
            vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = palette.base })
            vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = palette.surface0 })
            vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = palette.mantle })
            vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = palette.mantle })
            vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = palette.text, bg = palette.surface1, bold = true })
            vim.api.nvim_set_hl(0, "TelescopeSelectionCaret", { fg = palette.lavender, bg = palette.surface1 })
            vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = palette.lavender, bg = palette.surface0 })
            vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = palette.peach, bold = true })
          else
            -- Fallback to default links if Catppuccin is not available
            vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "FloatBorder" })
            vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "FloatBorder" })
            vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { link = "FloatBorder" })
            vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { link = "FloatBorder" })
          end
        end,
      })

      -- Apply immediately if colorscheme is already loaded
      vim.schedule(function()
        vim.cmd("doautocmd ColorScheme")
      end)
    end,
  },
}
