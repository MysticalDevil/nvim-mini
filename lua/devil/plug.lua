require("devil.utils").plug_add({
  "nvim-treesitter/nvim-treesitter",
  "olimorris/onedarkpro.nvim",
  "neovim/nvim-lspconfig",
  "folke/lazydev.nvim",
  "lewis6991/gitsigns.nvim",
  "nvim-mini/mini.icons",
})

vim.cmd("colorscheme onedark")

require("lazydev").setup({
  library = {
    "lazy.nvim",
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
  },
})

require("gitsigns").setup({
  attach_to_untracked = true,
  watch_gitdir = { follow_files = true },
  on_attach = function()
    vim.cmd("redrawstatus")
  end,
})
