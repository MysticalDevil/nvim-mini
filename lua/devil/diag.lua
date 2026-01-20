local signs = {
  [vim.diagnostic.severity.ERROR] = "󰅚 ",
  [vim.diagnostic.severity.WARN] = " ",
  [vim.diagnostic.severity.HINT] = "󰌶 ",
  [vim.diagnostic.severity.INFO] = " ",
}

local opts = {
  virtual_text = true,
  virtual_lines = { current_line = true },
  underline = true,
  signs = {
    text = signs,

    numhl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
      [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
      [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
      [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
    },
  },
  update_in_insert = false,
  show_header = false,
  severity_sort = true,
  float = {
    source = "if_many",
    border = "rounded",
    style = "minimal",
    header = "",
  },
}

vim.diagnostic.config(opts)
