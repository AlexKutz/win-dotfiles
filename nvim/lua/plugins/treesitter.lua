return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    -- В новых версиях мы вызываем setup напрямую у основного модуля
    require("nvim-treesitter").setup({
      -- Список языков для автоустановки
      ensure_installed = { 
        "lua", 
        "vim", 
        "vimdoc", 
        "query", 
        "javascript", 
        "typescript", 
        "python",
        "c_sharp"
      },
      
      -- Автоматическая установка отсутствующих парсеров
      auto_install = true,

      highlight = {
        enable = true,
        -- Отключаем для очень больших файлов, чтобы не тормозило
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
      },
      indent = { enable = true },
    })
  end,
}
