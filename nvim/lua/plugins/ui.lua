return {
  -- Цветовая схема
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- загружаем первым
    config = function()
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Статусная строка
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {}, -- эквивалентно require('lualine').setup({})
  },
}
