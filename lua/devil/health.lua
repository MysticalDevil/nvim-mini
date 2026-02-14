local M = {}

---Executable names expected for configured LSP servers.
---@type table<string, string>
local server_binaries = {
  lua_ls = "lua-language-server",
  gopls = "gopls",
  rust_analyzer = "rust-analyzer",
  zls = "zls",
}

---Append one rendered health line.
---@param lines string[]
---@param status string
---@param msg string
local function push(lines, status, msg)
  lines[#lines + 1] = string.format("[%s] %s", status, msg)
end

---Check Neovim baseline version.
---@param lines string[]
local function check_neovim(lines)
  local ok = vim.fn.has("nvim-0.12") == 1
  push(lines, ok and "OK" or "WARN", "Neovim >= 0.12")
end

---Check whether mise is available in PATH.
---@param lines string[]
local function check_mise(lines)
  local ok = vim.fn.executable("mise") == 1
  push(lines, ok and "OK" or "WARN", "mise available in PATH")
end

---Check each configured LSP executable.
---@param lines string[]
local function check_lsp_bins(lines)
  for server, bin in pairs(server_binaries) do
    local ok = vim.fn.executable(bin) == 1
    push(lines, ok and "OK" or "WARN", string.format("%s binary: %s", server, bin))
  end
end

---Check whether custom user commands are registered.
---@param lines string[]
local function check_commands(lines)
  local commands = { "PackSync", "TSInstallAll", "DiagVirtualLinesToggle", "KeymapHelp" }
  for _, cmd in ipairs(commands) do
    local ok = vim.fn.exists(":" .. cmd) == 2
    push(lines, ok and "OK" or "WARN", "command :" .. cmd)
  end
end

---Check Treesitter parser availability for current filetype.
---@param lines string[]
local function check_treesitter(lines)
  local ft = vim.bo.filetype
  if ft == nil or ft == "" then
    push(lines, "INFO", "Treesitter parser check skipped (no filetype)")
    return
  end

  local ok = pcall(vim.treesitter.language.get_lang, ft)
  push(lines, ok and "OK" or "WARN", string.format("Treesitter parser for filetype `%s`", ft))
end

---Render health report into a scratch markdown buffer.
function M.report()
  local lines = {
    "# DevilHealth",
    "",
  }

  check_neovim(lines)
  check_mise(lines)
  check_lsp_bins(lines)
  check_commands(lines)
  check_treesitter(lines)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_set_current_buf(buf)
end

---Register :DevilHealth command.
function M.setup()
  vim.api.nvim_create_user_command("DevilHealth", function()
    M.report()
  end, { desc = "Run minimal health checks for nvim-mini" })
end

return M
