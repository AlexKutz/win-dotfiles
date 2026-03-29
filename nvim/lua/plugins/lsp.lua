return {
  {
    "williamboman/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "vtsls", "basedpyright", "rust_analyzer" },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "prettier", "black", "ruff" },
    },
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        cs = { "dotnet_format" },
        python = { "ruff_format" },
        rust = { "rustfmt" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
      },
      -- Автоформатирование при сохранении
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { 'saghen/blink.cmp' },
    config = function()
      -- Получаем capabilities от blink.cmp
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Настройка Lua
      vim.lsp.config('lua_ls', {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        root_markers = { '.luarc.json', '.git' },
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } }
          }
        }
      })

      -- Настройка JavaScript / TypeScript (vtsls)
      vim.lsp.config('vtsls', {
        cmd = { 'vtsls' },
        filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
        root_markers = { 'package.json', 'tsconfig.json', '.git' },
        capabilities = capabilities,
        settings = {
          javascript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
              completeFunctionCalls = true,
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
          },
        },
      })

      -- Настройка Python (basedpyright)
      vim.lsp.config('basedpyright', {
        cmd = { 'basedpyright-langserver', '--stdio' },
        filetypes = { 'python' },
        root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
        capabilities = capabilities,
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "standard",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      -- Настройка Rust (rust-analyzer)
      vim.lsp.config('rust_analyzer', {
        cmd = { 'rust-analyzer' },
        filetypes = { 'rust' },
        root_markers = { 'Cargo.toml', '.git' },
        capabilities = capabilities,
        settings = {
          ['rust-analyzer'] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
            },
            checkOnSave = {
              allFeatures = true,
              command = 'clippy',
              extraArgs = { '--no-deps' },
            },
            procMacro = {
              enable = true,
              ignored = {
                ['async-trait'] = { 'async_trait' },
                ['napi-derive'] = { 'napi' },
                ['async-recursion'] = { 'async_recursion' },
              },
            },
            inlayHints = {
              bindingModeHints = {
                enable = false,
              },
              chainingHints = {
                enable = true,
              },
              closingBraceHints = {
                enable = true,
                minLines = 25,
              },
              closureReturnTypeHints = {
                enable = 'never',
              },
              lifetimeElisionHints = {
                enable = 'never',
                useParameterNames = false,
              },
              maxLength = 25,
              parameterHints = {
                enable = true,
              },
              reborrowHints = {
                enable = 'never',
              },
              renderColons = true,
              typeHints = {
                enable = true,
                hideClosureInitialization = false,
                hideNamedConstructor = false,
              },
            },
          },
        },
      })

      -- Активируем конфигурации
      vim.lsp.enable('lua_ls')
      vim.lsp.enable('vtsls')
      vim.lsp.enable('basedpyright')
      vim.lsp.enable('rust_analyzer')

      -- Настройка Roslyn (C#) для улучшенных completions
      vim.lsp.config('roslyn', {
        settings = {
          ["csharp|completion"] = {
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_provide_regex_completions = true,
            dotnet_show_name_completion_suggestions = true,
          },
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
          },
        },
      })

      -- Горячие клавиши
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          
          -- Проверяем, что это нужные сервера
          if client.name == 'lua_ls' or client.name == 'vtsls' or client.name == 'roslyn' or client.name == 'basedpyright' or client.name == 'rust_analyzer' then
            -- Горячие клавиши только для этих буферов
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
            vim.keymap.set({'n', 'v'}, '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr })
            vim.keymap.set({'n', 'v'}, '<leader>f', function()
              require('conform').format({ async = true, lsp_fallback = true })
            end, { buffer = bufnr, desc = "Format code" })
          end
        end,
      })
    end,
  },
  {
    "seblj/roslyn.nvim",
    ft = "cs",
    opts = {
      -- Выбор решения (.sln) при нескольких проектах
      choose_target = function(targets)
        -- Автовыбор .sln файла при наличии нескольких
        return vim.iter(targets):find(function(item)
          return item:match("%.sln$")
        end)
      end,
    },
  },
}
