local utils = require("devil.utils")

local M = {}

local function plug_install()
  utils.plug_add({
    "nvim-treesitter/nvim-treesitter",
    "olimorris/onedarkpro.nvim",
    "neovim/nvim-lspconfig",
    "folke/lazydev.nvim",
    "lewis6991/gitsigns.nvim",
    "nvim-mini/mini.icons",
  })
end

local function plug_setting()
  require("lazydev").setup({})

  require("gitsigns").setup({
    attach_to_untracked = true,
    watch_gitdir = { follow_files = true },
    on_attach = function()
      vim.cmd("redrawstatus")
    end,
  })

  require("nvim-treesitter").setup()
  require("nvim-treesitter").install({
    "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "rust", "zig", "go"
  }):wait(300000)
end

function M.setup()
  plug_install()
  plug_setting()
  vim.cmd("colorscheme onedark")
end

return M
