vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/olimorris/onedarkpro.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/folke/lazydev.nvim",
})
vim.cmd("colorscheme onedark")

require("lazydev").setup({
  library = {
    "lazy.nvim",
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
  },
})
