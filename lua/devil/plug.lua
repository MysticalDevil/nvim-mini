local utils = require("devil.utils")

local M = {}

---Install/sync plugin sources through vim.pack.
local function plug_install()
  utils.plug_add({
    "nvim-treesitter/nvim-treesitter",
    "folke/tokyonight.nvim",
    "neovim/nvim-lspconfig",
    "folke/lazydev.nvim",
    -- "j-hui/fidget.nvim",
    "lewis6991/gitsigns.nvim",
    "nvim-mini/mini.icons",
    "nvim-mini/mini.files",
    "ibhagwan/fzf-lua",
    "rcarriga/nvim-notify",
    "stevearc/conform.nvim",
  })
end

---Configure installed plugins.
local function plug_setting()
  require("mini.icons").setup()

  require("devil.notify").setup()
  require("devil.conform").setup()
  require("lazydev").setup({})
  -- require("fidget").setup({})
  require("fzf-lua").setup({})

  require("mini.files").setup({
    mappings = {
      close       = "q",
      go_in       = "l",
      go_in_plus  = "L",
      go_out      = "h",
      go_out_plus = "H",
      reset       = "<BS>",
      reveal_cwd  = "@",
      show_help   = "g?",
      synchronize = "=",
      trim_left   = "<",
      trim_right  = ">",
    },
    windows = {
      preview = true,
      width_focus = 30,
      width_preview = 40,
    },
  })

  require("gitsigns").setup({
    attach_to_untracked = true,
    watch_gitdir = { follow_files = true },
    on_attach = function()
      vim.cmd("redrawstatus")
    end,
  })

end

local function setup_builtin_tools()
  pcall(vim.cmd, "packadd nvim.undotree")
  pcall(vim.cmd, "packadd nvim.difftool")
end

---Treesitter parsers managed by this config.
---@type string[]
local ts_parsers = {
  "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "rust", "zig", "go",
}

---Install configured Treesitter parsers on demand.
local function install_treesitter_parsers()
  require("nvim-treesitter").install(ts_parsers)
end

---Register user commands for plugin/parser maintenance.
local function setup_user_commands()
  vim.api.nvim_create_user_command("PackSync", function()
    plug_install()
  end, { desc = "Install or sync configured vim.pack plugins" })

  vim.api.nvim_create_user_command("TSInstallAll", function()
    install_treesitter_parsers()
  end, { desc = "Install configured Treesitter parsers" })
end

---Bootstrap plugin layer and apply colorscheme fallback.
function M.setup()
  plug_install()
  setup_builtin_tools()
  plug_setting()
  setup_user_commands()

  -- Auto-install configured Treesitter parsers shortly after startup.
  vim.defer_fn(function()
    pcall(install_treesitter_parsers)
  end, 100)

  vim.cmd("colorscheme tokyonight")
end

return M
