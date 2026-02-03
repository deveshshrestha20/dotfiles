return {
  "3rd/image.nvim", -- Correct repo
  lazy = true,
  event = "BufReadPost", -- Load when opening a markdown file
  config = function()
    local status_ok, image = pcall(require, "image")
    if not status_ok then
      vim.notify("image.nvim not found!", vim.log.levels.WARN)
      return
    end

    -- Setup image.nvim
    image.setup({
      backend = "kitty",
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          only_render_image_at_cursor_mode = "popup",
          floating_windows = false,
          filetypes = { "markdown", "vimwiki" },
        },
      },
      max_width = nil,
      max_height = nil,
      max_height_window_percentage = 70,
      scale_factor = 1.0,
      hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
    })

    -- Automatically convert Obsidian ![[...]] links to Markdown
    vim.api.nvim_create_autocmd("BufReadPost", {
      pattern = "*.md",
      callback = function()
        local ok, obsidian = pcall(require, "obsidian")
        if not ok then
          return
        end

        local vault = obsidian.get_vault_path()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        for i, line in ipairs(lines) do
          local new_line = line:gsub("!%[%[(.-)%]%]", function(fname)
            return "![" .. fname .. "](" .. vault .. "/" .. fname .. ")"
          end)

          if new_line ~= line then
            vim.api.nvim_buf_set_lines(0, i - 1, i, false, { new_line })
          end
        end

        -- Render images after conversion
        image.render_buffer()
      end,
    })
  end,
}
