local M = {}

---Normalize keymap mode field for display.
---@param mode string|string[]
---@return string
local function normalize_mode(mode)
  if type(mode) == "table" then
    return table.concat(mode, ",")
  end
  return tostring(mode)
end

---Collect keymap descriptions for help buffer rendering.
---@return string[]
local function collect_lines()
  local km = require("devil.keymap")
  local lines = {
    "# Keymap Help",
    "",
    "General mappings:",
  }

  for _, map in ipairs(km.general) do
    lines[#lines + 1] = string.format("- [%s] %s -> %s", normalize_mode(map.mode), map.lhs, map.desc or "")
  end

  lines[#lines + 1] = ""
  lines[#lines + 1] = "LSP mappings:"
  for _, map in ipairs(km.lsp) do
    lines[#lines + 1] = string.format("- [%s] %s -> %s", normalize_mode(map.mode), map.lhs, map.desc or "")
  end

  return lines
end

---Open keymap help in a scratch markdown buffer.
function M.open_keymap_help()
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = collect_lines()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_set_current_buf(buf)
end

---Register :KeymapHelp command.
function M.setup()
  vim.api.nvim_create_user_command("KeymapHelp", function()
    M.open_keymap_help()
  end, { desc = "Open mapping cheat sheet" })
end

return M
