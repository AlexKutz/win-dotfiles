# Neovim Configuration Documentation

## Overview

This Neovim configuration provides a modern IDE-like experience with LSP support, autocompletion, syntax highlighting, and formatting for multiple programming languages.

**Location:** `c:\Users\alex\win-dotfiles\nvim`

---

## File Structure

```
nvim/
├── init.lua              # Entry point - loads lazy.nvim
├── lazy-lock.json        # Plugin version lockfile
├── lua/
│   ├── config/
│   │   └── lazy.lua      # Package manager bootstrap
│   └── plugins/
│       ├── blink.lua     # Autocompletion engine
│       ├── lsp.lua       # LSP servers & formatting
│       ├── treesitter.lua # Syntax highlighting
│       └── ui.lua        # Theme & status line
```

---

## 1. Package Manager: lazy.nvim

**File:** `lua/config/lazy.lua`

### Features
- **Bootstrap:** Auto-clones from GitHub if not present
- **Leader Key:** `Space`
- **Plugin Discovery:** Automatically loads all `.lua` files from `lua/plugins/`
- **Auto-updates:** Checks for plugin updates automatically

### Configuration
```lua
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
```

---

## 2. LSP Configuration

**File:** `lua/plugins/lsp.lua`

### Mason Ecosystem

| Plugin | Purpose |
|--------|---------|
| `mason.nvim` | LSP/DAP/linter installer with custom registries |
| `mason-lspconfig.nvim` | Bridges Mason with nvim-lspconfig |
| `mason-tool-installer.nvim` | Ensures CLI tools are installed |

### Configured Language Servers

#### Lua (`lua_ls`)
```lua
vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.git' },
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } }
    }
  }
})
```

#### JavaScript/TypeScript (`vtsls`)
```lua
vim.lsp.config('vtsls', {
  cmd = { 'vtsls' },
  filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
  root_markers = { 'package.json', 'tsconfig.json', '.git' },
  settings = {
    javascript = {
      updateImportsOnFileMove = { enabled = "always" },
      suggest = { completeFunctionCalls = true },
    },
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
    },
  },
})
```

#### Python (`basedpyright`)
```lua
vim.lsp.config('basedpyright', {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
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
```

#### Rust (`rust_analyzer`)
```lua
vim.lsp.config('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', '.git' },
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
        loadOutDirsFromCheck = true,
        buildScripts = { enable = true },
      },
      checkOnSave = {
        allFeatures = true,
        command = 'clippy',
        extraArgs = { '--no-deps' },
      },
      procMacro = { enable = true },
      inlayHints = {
        chainingHints = { enable = true },
        parameterHints = { enable = true },
        typeHints = { enable = true },
      },
    },
  },
})
```

#### C# (`roslyn` via roslyn.nvim)
```lua
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
```

### LSP Keybindings

All keybindings are buffer-local and apply to configured LSP servers:

| Key | Action |
|-----|--------|
| `K` | Hover documentation |
| `gd` | Go to definition |
| `<leader>ca` | Code actions |
| `<leader>f` | Format code |

---

## 3. Autocompletion: blink.cmp

**File:** `lua/plugins/blink.lua`

### Features
- **Sources:** LSP, path, snippets, buffer
- **Snippets:** Uses `friendly-snippets` for common patterns
- **UI:** Rounded borders, nerd font icons, ghost text

### Keymap
| Key | Action |
|-----|--------|
| `Tab` | Select next item |
| `Enter` | Confirm selection |
| `<C-space>` | Show/hide completion menu |

### Configuration Highlights
```lua
opts = {
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
    ghost_text = { enabled = true },
  },
  signature = { enabled = true },
}
```

---

## 4. Syntax Highlighting: nvim-treesitter

**File:** `lua/plugins/treesitter.lua`

### Configured Parsers
- `lua`, `vim`, `vimdoc`, `query`
- `javascript`, `typescript`
- `python`, `c_sharp`

### Features
- **Auto-install:** Missing parsers installed automatically
- **Performance:** Highlighting disabled for files > 100KB
- **Indentation:** Enabled for all languages

```lua
require("nvim-treesitter").setup({
  ensure_installed = { "lua", "vim", "javascript", "typescript", "python", "c_sharp" },
  auto_install = true,
  highlight = { enable = true },
  indent = { enable = true },
})
```

---

## 5. Formatting: conform.nvim

**File:** `lua/plugins/lsp.lua` (lines 24-42)

### Formatters by Filetype

| Language | Formatter |
|----------|-----------|
| C# | `dotnet_format` |
| Python | `ruff_format` |
| Rust | `rustfmt` |
| JavaScript | `prettier` |
| TypeScript | `prettier` |
| JavaScriptReact | `prettier` |
| TypeScriptReact | `prettier` |

### Auto-format on Save
```lua
format_on_save = {
  timeout_ms = 500,
  lsp_fallback = true,
}
```

---

## 6. Component Integration

### How It Works Together

1. **lazy.nvim** loads plugins from `lua/plugins/`
2. **mason.nvim** installs LSP servers automatically on first run
3. **nvim-lspconfig** configures servers using Neovim 0.11+ native `vim.lsp.config()` API
4. **blink.cmp** receives LSP capabilities for intelligent completions
5. **conform.nvim** handles formatting with LSP fallback
6. **treesitter** provides fast, accurate syntax highlighting

### Data Flow
```
User types → blink.cmp shows suggestions
                ↓
        LSP server provides completions
                ↓
    User saves → conform.nvim formats
                ↓
        LSP diagnostics update in real-time
```

---

## 7. Language Support Matrix

| Language | LSP | Formatting | Special Features |
|----------|-----|------------|------------------|
| **Lua** | lua_ls | - | `vim` global recognized in diagnostics |
| **JavaScript** | vtsls | prettier | Auto-imports on file move, complete function calls |
| **TypeScript** | vtsls | prettier | Same as JavaScript |
| **Python** | basedpyright | ruff | Standard type checking mode |
| **Rust** | rust_analyzer | rustfmt | Clippy on save, inlay hints, proc macro support |
| **C#** | roslyn | dotnet_format | Solution auto-selection, unimported namespace completions |

---

## 8. Installation & Setup

### Prerequisites
- Neovim 0.11+
- Git
- Node.js (for some LSP servers)
- Rust toolchain (for rust-analyzer)
- .NET SDK (for roslyn)

### First Run
1. Start Neovim
2. lazy.nvim will bootstrap automatically
3. Run `:Mason` to verify LSP servers are installing
4. Restart Neovim after installations complete

### Updating
Run `:Lazy update` to update all plugins
Run `:MasonUpdate` to update LSP servers

---

## 9. Customization

### Adding a New Language Server
1. Add to `ensure_installed` in mason-lspconfig.nvim
2. Add `vim.lsp.config()` block
3. Add `vim.lsp.enable()` call
4. Update LSP keybinding filter if needed

### Adding a New Formatter
1. Install via mason-tool-installer.nvim or system package manager
2. Add to `formatters_by_ft` in conform.nvim

---

## 10. Troubleshooting

### LSP not starting
- Check `:LspInfo` for attached clients
- Verify server is installed: `:Mason`
- Check root markers exist in project

### Completions not appearing
- Verify blink.cmp is loaded: `:Lazy`
- Check LSP is attached and running

### Formatting not working
- Check formatter is installed: `:ConformInfo`
- Verify filetype is configured
