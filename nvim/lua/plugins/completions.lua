return {
  {
    "hrsh7th/nvim-cmp",
    enabled = true,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "kdheepak/cmp-latex-symbols",
      "zbirenbaum/copilot-cmp",
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
          local luasnip = require("luasnip")

          -- Load friendly snippets
          require("luasnip.loaders.from_vscode").lazy_load()

          -- Load netcore-snippets
          require("luasnip.loaders.from_vscode").lazy_load({
            paths = { vim.fn.expand("~/.config/nvim/snippets/netcore-snippets") },
          })

          -- Load custom Lua snippets
          require("luasnip.loaders.from_lua").lazy_load({
            paths = { vim.fn.expand("~/.config/nvim/lua/snippets") },
          })

          -- LuaSnip settings
          luasnip.config.set_config({
            history = true,
            updateevents = "TextChanged,TextChangedI",
            enable_autosnippets = true,
          })
        end,
      },
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- Custom kind icons
      local kind_icons = {
        Copilot = "",
        Text = "󰆈",
        Method = "∂",
        Function = "󰊕",
        Constructor = "",
        Field = "󰜢",
        Variable = "󰀫",
        Class = "󰠱",
        Interface = "",
        Module = "⌠",
        Property = "󰀫",
        Unit = "",
        Value = "",
        Enum = "τ",
        Keyword = "k",
        Snippet = "",
        Color = "󰏘",
        File = "󰈙",
        Reference = "󰈇",
        Folder = "󰉋",
        EnumMember = "",
        Constant = "󰏿",
        Struct = "󰙅",
        Event = "",
        Operator = "󰆕",
        TypeParameter = "",
      }

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "copilot", priority = 1100, max_item_count = 3 },
          { name = "luasnip", priority = 1000, max_item_count = 5 },
          { name = "nvim_lsp", priority = 900, max_item_count = 20 },
          { name = "path", priority = 800 },
          { name = "latex_symbols", priority = 700 },
        }, {
          { name = "buffer", priority = 500, keyword_length = 3 },
        }),
        matching = {
          disallow_fuzzy_matching = false,
          disallow_partial_matching = false,
          disallow_prefix_unmatching = false,
        },
        sorting = {
          priority_weight = 2,
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
        formatting = {
          fields = { "abbr", "kind", "menu" },
          format = function(entry, vim_item)
            -- Special handling for Copilot
            if entry.source.name == "copilot" then
              vim_item.kind = kind_icons.Copilot
              vim_item.menu = "[Copilot]"
              return vim_item
            end

            -- Show only icon for other kinds
            local kind = vim_item.kind
            vim_item.kind = kind_icons[kind] or kind_icons.Text

            -- Add source menu
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              buffer = "[Buf]",
              path = "[Path]",
              latex_symbols = "[LaTeX]",
            })[entry.source.name]

            -- Truncate long completion text
            if #vim_item.abbr > 50 then
              vim_item.abbr = string.sub(vim_item.abbr, 1, 47) .. "..."
            end

            return vim_item
          end,
        },
        window = {
          completion = {
            border = "rounded",
            winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
            scrollbar = true,
            col_offset = -3,
            side_padding = 1,
          },
          documentation = {
            border = "none",
            winhighlight = "Normal:Pmenu,FloatBorder:PmenuBorder",
            max_height = 15,
            max_width = 60,
          },
        },
        experimental = {
          ghost_text = false,
        },
      })

      -- Better highlight groups for completion menu
      vim.cmd([[
        highlight! CmpItemAbbrDeprecated guifg=#7E8E91 gui=strikethrough
        highlight! CmpItemAbbrMatch guifg=#82AAFF gui=bold
        highlight! CmpItemAbbrMatchFuzzy guifg=#82AAFF gui=bold
        highlight! CmpItemMenu guifg=#C792EA gui=italic
        
        highlight! CmpItemKindField guifg=#B5585F
        highlight! CmpItemKindProperty guifg=#B5585F
        highlight! CmpItemKindEvent guifg=#B5585F
        
        highlight! CmpItemKindText guifg=#9FBD73
        highlight! CmpItemKindEnum guifg=#9FBD73
        highlight! CmpItemKindKeyword guifg=#9FBD73
        
        highlight! CmpItemKindConstant guifg=#D4BB6C
        highlight! CmpItemKindConstructor guifg=#D4BB6C
        highlight! CmpItemKindReference guifg=#D4BB6C
        
        highlight! CmpItemKindFunction guifg=#A377BF
        highlight! CmpItemKindStruct guifg=#A377BF
        highlight! CmpItemKindClass guifg=#A377BF
        highlight! CmpItemKindModule guifg=#A377BF
        highlight! CmpItemKindOperator guifg=#A377BF
        
        highlight! CmpItemKindVariable guifg=#7E8E91
        highlight! CmpItemKindFile guifg=#7E8E91
        
        highlight! CmpItemKindUnit guifg=#D4A959
        highlight! CmpItemKindSnippet guifg=#D4A959
        highlight! CmpItemKindFolder guifg=#D4A959
        
        highlight! CmpItemKindMethod guifg=#6C8ED4
        highlight! CmpItemKindValue guifg=#6C8ED4
        highlight! CmpItemKindEnumMember guifg=#6C8ED4
        
        highlight! CmpItemKindInterface guifg=#58B5A8
        highlight! CmpItemKindColor guifg=#58B5A8
        highlight! CmpItemKindTypeParameter guifg=#58B5A8
        
        highlight! CmpItemKindCopilot guifg=#6CC644
        highlight! FloatBorder guibg=#1e1e2e guifg=#6c7086
        highlight! NormalFloat guibg=#1e1e2e
      ]])

      -- Command line completions
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })

      -- Search completions
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })
    end,
  },
}
