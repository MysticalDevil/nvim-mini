vim.g.mapleader = " "
vim.g.maplocalleader = " "

local M = {}

local space_visible = false

M.general = {
  -----------------------------------------------------------------------------
  -- Magic Search
  -----------------------------------------------------------------------------
  { mode = { "n", "v" }, lhs = "/", rhs = "/\\v", desc = "Magic search", opts = { silent = false } },

  -----------------------------------------------------------------------------
  -- Insert Mode (i)
  -----------------------------------------------------------------------------
  { mode = "i", lhs = "<C-b>", rhs = "<ESC>^i", desc = "Beginning of line" },
  { mode = "i", lhs = "<C-e>", rhs = "<End>", desc = "End of line" },
  { mode = "i", lhs = "<C-h>", rhs = "<Left>", desc = "Move left" },
  { mode = "i", lhs = "<C-l>", rhs = "<Right>", desc = "Move right" },
  { mode = "i", lhs = "<C-j>", rhs = "<Down>", desc = "Move down" },
  { mode = "i", lhs = "<C-k>", rhs = "<Up>", desc = "Move up" },

  -----------------------------------------------------------------------------
  -- Normal Mode (n)
  -----------------------------------------------------------------------------
  { mode = "n", lhs = "<Esc>", rhs = "<cmd> noh <CR>", desc = "Clear highlight" },
  { mode = "n", lhs = "<C-d>", rhs = "10j", desc = "Ten lines down" },
  { mode = "n", lhs = "<C-u>", rhs = "10k", desc = "Ten lines up" },

  {
    mode = "n",
    lhs = "j",
    rhs = 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"',
    desc = "Move down",
    opts = { expr = true },
  },
  {
    mode = "n",
    lhs = "k",
    rhs = 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"',
    desc = "Move up",
    opts = { expr = true },
  },
  {
    mode = "n",
    lhs = "<Up>",
    rhs = 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"',
    desc = "Move up",
    opts = { expr = true },
  },
  {
    mode = "n",
    lhs = "<Down>",
    rhs = 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"',
    desc = "Move down",
    opts = { expr = true },
  },

  { mode = "n", lhs = "<leader>bn", rhs = "<cmd> enew <CR>", desc = "New buffer" },
  { mode = "n", lhs = "<leader>ch", rhs = "<cmd> NvCheatsheet <CR>", desc = "Mapping cheatsheet" },
  {
    mode = "n",
    lhs = "<leader>fm",
    rhs = function()
      vim.lsp.buf.format({ async = true })
    end,
    desc = "LSP formatting",
  },

  {
    mode = "n",
    lhs = "<Space>th",
    rhs = function()
      if space_visible then
        vim.opt.listchars:remove("space:·")
      else
        vim.opt.listchars:append("space:·")
      end
      space_visible = not space_visible
    end,
    desc = "Toggle space visible status",
  },

  { mode = "n", lhs = "<leader>wv", rhs = ":vsp<CR>", desc = "Split window vertically" },
  { mode = "n", lhs = "<leader>wh", rhs = ":sp<CR>", desc = "Split window horizontally" },
  { mode = "n", lhs = "<leader>wc", rhs = "<C-w>c", desc = "Close picked split window" },
  { mode = "n", lhs = "<leader>wo", rhs = "<C-w>o", desc = "Close other split window" },
  { mode = "n", lhs = "<leader>w,", rhs = ":vertical resize -10<CR>", desc = "Reduce vertical window size" },
  { mode = "n", lhs = "<leader>w.", rhs = ":vertical resize +10<CR>", desc = "Increase vertical window size" },
  { mode = "n", lhs = "<leader>wj", rhs = ":horizontal resize -5<CR>", desc = "Reduce horizontal window size" },
  { mode = "n", lhs = "<leader>wk", rhs = ":horizontal resize +5<CR>", desc = "Increase horizontal window size" },
  { mode = "n", lhs = "<leader>w=", rhs = "<C-w>=", desc = "Make split windows equal in size" },

  { mode = "n", lhs = "<leader><Tab>s", rhs = "<cmd>tab split<CR>", desc = "Split window use tab" },
  { mode = "n", lhs = "<leader><Tab>h", rhs = "<cmd>tabprev<CR>", desc = "Switch to previous tab" },
  { mode = "n", lhs = "<leader><Tab>j", rhs = "<cmd>tabnext<CR>", desc = "Switch to next tab" },
  { mode = "n", lhs = "<leader><Tab>f", rhs = "<cmd>tabfirst<CR>", desc = "Switch to first tab" },
  { mode = "n", lhs = "<leader><Tab>l", rhs = "<cmd>tablast<CR>", desc = "Switch to last tab" },
  { mode = "n", lhs = "<leader><Tab>c", rhs = "<cmd>tabclose<CR>", desc = "Close tab" },

  { mode = "n", lhs = "zo", rhs = "<CMD>foldopen<CR>", desc = "Open fold" },
  { mode = "n", lhs = "zc", rhs = "<CMD>foldclose<CR>", desc = "Close fold" },

  -----------------------------------------------------------------------------
  -- Visual Mode (v)
  -----------------------------------------------------------------------------
  { mode = "v", lhs = "<C-j>", rhs = "5j", desc = "Five lines down" },
  { mode = "v", lhs = "<C-k>", rhs = "5k", desc = "Five lines up" },
  { mode = "v", lhs = "<C-d>", rhs = "10j", desc = "Ten lines down" },
  { mode = "v", lhs = "<C-u>", rhs = "10k", desc = "Ten lines up" },
  {
    mode = "v",
    lhs = "<Up>",
    rhs = 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"',
    desc = "Move up",
    opts = { expr = true },
  },
  {
    mode = "v",
    lhs = "<Down>",
    rhs = 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"',
    desc = "Move down",
    opts = { expr = true },
  },

  { mode = "v", lhs = "<", rhs = "<gv", desc = "Indent line" },
  { mode = "v", lhs = ">", rhs = ">gv", desc = "Indent line" },

  -----------------------------------------------------------------------------
  -- Visual Block / Select Mode (x)
  -----------------------------------------------------------------------------
  {
    mode = "x",
    lhs = "j",
    rhs = 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"',
    desc = "Move down",
    opts = { expr = true },
  },
  {
    mode = "x",
    lhs = "k",
    rhs = 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"',
    desc = "Move up",
    opts = { expr = true },
  },

  {
    mode = "x",
    lhs = "p",
    rhs = 'p:let @+=@0<CR>:let @"=@0<CR>',
    desc = "Dont copy replaced text",
    opts = { silent = true },
  },

  -----------------------------------------------------------------------------
  -- Command Mode (c)
  -----------------------------------------------------------------------------
  { mode = "c", lhs = "<C-j>", rhs = "<C-n>", desc = "Next line" },
  { mode = "c", lhs = "<C-k>", rhs = "<C-p>", desc = "Previous line" },

  -----------------------------------------------------------------------------
  -- Terminal Mode (t)
  -----------------------------------------------------------------------------
  { mode = "t", lhs = "<ESC>", rhs = "<C-\\><C-n>", desc = "Back to normal mode" },
  {
    mode = "t",
    lhs = "<C-x>",
    rhs = vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true),
    desc = "Escape terminal mode",
  },
}

M.lsp = {
  { mode = "n", lhs = "gd", rhs = vim.lsp.buf.definition, desc = "Go to definition" },
  { mode = "n", lhs = "gr", rhs = vim.lsp.buf.references, desc = "Find references" },
  { mode = "n", lhs = "gD", rhs = vim.lsp.buf.declaration, desc = "Go to declaration" },
  { mode = "n", lhs = "gi", rhs = vim.lsp.buf.implementation, desc = "Go to implementation" },
  { mode = "n", lhs = "K", rhs = vim.lsp.buf.hover, desc = "Hover" },
  { mode = "n", lhs = "<leader>rn", rhs = vim.lsp.buf.rename, desc = "Rename symbol" },
  { mode = "n", lhs = "<leader>ca", rhs = vim.lsp.buf.code_action, desc = "Code action" },
  {
    mode = "n",
    lhs = "<leader>fm",
    rhs = function()
      vim.lsp.buf.format({ async = true })
    end,
    desc = "Format (LSP)",
  },
  {
    mode = "n",
    lhs = "[d",
    rhs = function()
      vim.diagnostic.jump({ count = 1, float = { border = "rounded" } })
    end,
    desc = "Prev diagnostic",
  },
  {
    mode = "n",
    lhs = "]d",
    rhs = function()
      vim.diagnostic.jump({ count = 1, float = { border = "rounded" } })
    end,
    desc = "Next diagnostic",
  },
  { mode = "n", lhs = "<leader>e", rhs = vim.diagnostic.open_float, desc = "Diagnostic float" },
  { mode = "n", lhs = "<leader>q", rhs = vim.diagnostic.setloclist, desc = "Diagnostics to loclist" },
}

return M
