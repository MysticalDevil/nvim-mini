local utils = require("devil.utils")

local M = {}

local ts_parsers = {
  "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "rust", "zig", "go",
}

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
end

local function install_treesitter_parsers()
  require("nvim-treesitter").install(ts_parsers)
end

local function setup_user_commands()
  vim.api.nvim_create_user_command("PackSync", function()
    plug_install()
  end, { desc = "Install or sync configured vim.pack plugins" })

  vim.api.nvim_create_user_command("TSInstallAll", function()
    install_treesitter_parsers()
  end, { desc = "Install configured Treesitter parsers" })
end

function M.setup()
  plug_install()
  plug_setting()
  setup_user_commands()
  local ok = pcall(vim.cmd.colorscheme, "onedark")
  if not ok then
    vim.cmd.colorscheme("habamax")
  end
end

return M
