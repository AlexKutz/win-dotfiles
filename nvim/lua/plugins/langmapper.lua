return {
  'Wansmer/langmapper.nvim',
  lazy = false,
  priority = 1, -- High priority is needed if you will use `autoremap()`
  config = function()
    -- Helper function to escape special characters for langmap
    local function escape(str)
      local escape_chars = [[;,\."|\]]
      return vim.fn.escape(str, escape_chars)
    end

    -- Define English and Russian layouts
    local en = [[`qwertyuiop[]asdfghjkl;'zxcvbnm]]
    local ru = [[ёйцукенгшщзхъфывапролджэячсмить]]
    local en_shift = [[~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>]]
    local ru_shift = [[ËЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ]]

    -- Set up langmap for normal mode commands
    vim.opt.langmap = vim.fn.join({
      escape(ru_shift) .. ';' .. escape(en_shift),
      escape(ru) .. ';' .. escape(en),
    }, ',')

    require('langmapper').setup({
      -- Add mapping for every CTRL+ binding
      map_all_ctrl = true,
      -- Modes to apply ctrl mappings
      ctrl_map_modes = { 'n', 'o', 'i', 'c', 't', 'v' },
      -- Wrap all keymap functions for automatic translation
      hack_keymap = true,
      -- Don't hack insert mode (prevents issues with typing)
      disable_hack_modes = { 'i' },
      -- Modes for automapping
      automapping_modes = { 'n', 'v', 'x', 's' },
      -- Default English layout
      default_layout = [[ABCDEFGHIJKLMNOPQRSTUVWXYZ<>:"{}~abcdefghijklmnopqrstuvwxyz,.;'[]`]],
      -- Layout configurations
      layouts = {
        ru = {
          -- Windows Russian layout identifier
          id = '00000419',
          -- Russian layout mapping
          layout = 'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯБЮЖЭХЪËфисвуапршолдьтщзйкыегмцчнябюжэхъё',
        },
      },
      -- OS-specific settings
      os = {
        Windows = {
          -- Function to get current keyboard layout on Windows
          get_current_layout_id = function()
            -- Use PowerShell to get current keyboard layout
            local cmd = 'powershell -Command "[System.Windows.Forms.InputLanguage]::CurrentInputLanguage.Culture.KeyboardLayoutId"'
            local handle = io.popen(cmd)
            if handle then
              local result = handle:read('*a')
              handle:close()
              return vim.trim(result)
            end
          end,
        },
      },
    })

    -- Auto-translate all existing mappings at the end of init
    -- This handles built-in mappings and vim script mappings
    vim.defer_fn(function()
      require('langmapper').automapping({ global = true, buffer = true })
    end, 100)
  end,
}