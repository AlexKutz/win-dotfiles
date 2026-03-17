return {
  'saghen/blink.cmp',
  -- Загружаем при наборе текста (Insert mode)
  event = "InsertEnter",
  version = '*',
  -- Набор готовых сниппетов (React, JS, Python и т.д.)
  dependencies = 'rafamadriz/friendly-snippets',

  opts = {
    -- Настройка клавиш
    keymap = { 
      preset = 'default', -- Tab для выбора, Enter для подтверждения
      ['<C-space>'] = { 'show', 'show_documentation', 'hide' },
    },

    appearance = {
      -- Использовать иконки из nvim-web-devicons (если установлены)
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono'
    },

    -- Настройка самого меню
    completion = {
      menu = {
        border = 'rounded', -- Красивые скругленные края
        draw = {
          -- Колонки в меню: Иконка | Название | Тип (Function/Variable)
          columns = { { "kind_icon", gap = 1 }, { "label", "label_description", gap = 1 } },
        },
      },
      -- Автоматически показывать документацию к методу справа
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = { border = 'rounded' },
      },
      -- Визуальная подсказка (серый текст) того, что будет вставлено
      ghost_text = { enabled = true },
    },

    -- Источники данных
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    -- Настройка сигнатур функций (подсказка аргументов внутри скобок)
    signature = { 
      enabled = true,
      window = { border = 'rounded' }
    },
  },
}
