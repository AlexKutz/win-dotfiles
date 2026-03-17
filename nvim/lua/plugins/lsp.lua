return {
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "vtsls" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { 'saghen/blink.cmp' },
    config = function()
      -- Получаем capabilities от blink.cmp
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- НОВЫЙ СТИЛЬ: Вместо require('lspconfig') используем vim.lsp.config
      
      -- Настройка Lua
      vim.lsp.config('lua_ls', {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } }
          }
        }
      })

      -- Настройка JavaScript / TypeScript (vtsls)
      vim.lsp.config('vtsls', {
        capabilities = capabilities,
        settings = {
          javascript = {
            updateImportsOnFileMove = { enabled = "always" },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
          },
        },
      })

      -- Запускаем настроенные сервера
      vim.lsp.enable('lua_ls')
      vim.lsp.enable('vtsls')

      -- Горячие клавиши
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set({'n', 'v'}, '<leader>ca', vim.lsp.buf.code_action, {})
    end,
  },
}
