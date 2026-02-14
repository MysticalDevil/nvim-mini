local signs = {
  [vim.diagnostic.severity.ERROR] = "E",
  [vim.diagnostic.severity.WARN] = "W",
  [vim.diagnostic.severity.INFO] = "I",
  [vim.diagnostic.severity.HINT] = "H",
}

---Default diagnostic configuration.
---@type vim.diagnostic.Opts
local opts = {
  virtual_text = { source = true },
  virtual_lines = false,
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

local M = {}

---Tracks virtual_lines state for toggle command.
local virtual_lines_enabled = false

---Toggle diagnostic virtual_lines for the current session.
function M.toggle_virtual_lines()
  virtual_lines_enabled = not virtual_lines_enabled
  vim.diagnostic.config({
    virtual_lines = virtual_lines_enabled and { current_line = true } or false,
  })
  vim.notify(
    string.format("diagnostic virtual_lines: %s", virtual_lines_enabled and "on" or "off"),
    vim.log.levels.INFO
  )
end

---Apply diagnostic defaults and register related user commands.
function M.setup()
  vim.diagnostic.config(opts)
  vim.api.nvim_create_user_command("DiagVirtualLinesToggle", function()
    M.toggle_virtual_lines()
  end, { desc = "Toggle diagnostic virtual lines" })
end

return M
