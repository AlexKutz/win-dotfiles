return {
  'saghen/blink.cmp',
  -- Загружаем при наборе текста (Insert mode)
  version = '*',
  -- Набор готовых сниппетов (React, JS, Python и т.д.)
  dependencies = 'rafamadriz/friendly-snippets',

  opts = {
    -- Настройка клавиш
    keymap = {
      preset = 'none', -- Отключаем стандартный preset
      ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>'] = { 'hide', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },
      ['<Tab>'] = { 'snippet_forward', 'select_next', 'fallback' },
      ['<S-Tab>'] = { 'snippet_backward', 'select_prev', 'fallback' },
      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<C-n>'] = { 'select_next', 'fallback' },
      ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
    },

    appearance = {
      -- Использовать иконки из nvim-web-devicons (если установлены)
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono'
    },

    -- Источники данных
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    -- Настройка сортировки результатов
    fuzzy = {
      sorts = {
        -- Точный матч в начале строки - highest priority
        'exact',
        -- Приоритет по score (релевантность)
        'score',
        -- Сортировка по локали (алфавит)
        'sort_text',
      },
    },

    -- Приоритизация LSP результатов
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
      -- Выбирать первый элемент автоматически
      list = {
        selection = {
          preselect = function(ctx)
            return ctx.mode == 'cmdline' and 'none' or 'preselect'
          end,
          cycles = true,
        },
      },
    },

    -- Настройка сигнатур функций (подсказка аргументов внутри скобок)
    signature = { 
      enabled = true,
      window = { border = 'rounded' }
    },
  },
}
