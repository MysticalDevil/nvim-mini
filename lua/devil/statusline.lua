local M = {}

local icons = require("mini.icons")

local function get_hl(name)
  return vim.api.nvim_get_hl(0, { name = name, link = true }) or {}
end

local function pick_contrast_fg(bg)
  if not bg then
    return get_hl("Normal").fg
  end

  local r = math.floor(bg / 0x10000) % 0x100
  local g = math.floor(bg / 0x100) % 0x100
  local b = bg % 0x100
  local luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b

  if luminance > 140 then
    return 0x000000
  end
  return 0xFFFFFF
end

local function get_color(group_name)
  local hl = vim.api.nvim_get_hl(0, { name = group_name, link = false })
  if not hl or not hl.fg then return nil end
  return hl.fg
end

local function set_highlights()
  local function set_mode_hl(name, link_group)
    local color = get_color(link_group)
    if not color then return end

    local status = get_hl("StatusLine")
    local normal = get_hl("Normal")
    local base_bg = status.bg or normal.bg

    vim.api.nvim_set_hl(0, "StatusLineMode" .. name, {
      fg = color,
      bg = base_bg,
    })

    vim.api.nvim_set_hl(0, "StatusLineMode" .. name .. "Text", {
      fg = pick_contrast_fg(color),
      bg = color,
      bold = true,
    })
  end

  set_mode_hl("Normal", "String")
  set_mode_hl("Insert", "Function")
  set_mode_hl("Visual", "Keyword")
  set_mode_hl("Command", "WarningMsg")
  set_mode_hl("Replace", "ErrorMsg")

  vim.api.nvim_set_hl(0, "StatusLineGitAdded", { link = "GitSignsAdd" })
  vim.api.nvim_set_hl(0, "StatusLineGitChanged", { link = "GitSignsChange" })
  vim.api.nvim_set_hl(0, "StatusLineGitRemoved", { link = "GitSignsDelete" })

  vim.api.nvim_set_hl(0, "StatusLineGit", { link = "Comment" })
  vim.api.nvim_set_hl(0, "StatusLineFile", { link = "Directory" })

  vim.api.nvim_set_hl(0, "StatusLineDiagError", { link = "DiagnosticError" })
  vim.api.nvim_set_hl(0, "StatusLineDiagWarn", { link = "DiagnosticWarn" })
  vim.api.nvim_set_hl(0, "StatusLineDiagInfo", { link = "DiagnosticInfo" })
  vim.api.nvim_set_hl(0, "StatusLineDiagHint", { link = "DiagnosticHint" })

  vim.api.nvim_set_hl(0, "StatusLineLspActive", { link = "DiagnosticHint" })
  vim.api.nvim_set_hl(0, "StatusLineLspInactive", { link = "Comment" })
end

local aug = vim.api.nvim_create_augroup("MyStatusline", { clear = true })

set_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = aug,
  callback = set_highlights,
})

vim.api.nvim_create_autocmd("User", {
  group = aug,
  pattern = "GitSignsUpdate",
  callback = function()
    vim.cmd("redrawstatus")
  end,
})

local mode_map = {
  ["n"] = { name = "NORMAL", hl = "Normal" },
  ["no"] = { name = "O-PENDING", hl = "Normal" },
  ["i"] = { name = "INSERT", hl = "Insert" },
  ["ic"] = { name = "INSERT", hl = "Insert" },
  ["t"] = { name = "TERMINAL", hl = "Insert" },
  ["v"] = { name = "VISUAL", hl = "Visual" },
  ["V"] = { name = "V-LINE", hl = "Visual" },
  ["\22"] = { name = "V-BLOCK", hl = "Visual" },
  ["R"] = { name = "REPLACE", hl = "Replace" },
  ["c"] = { name = "COMMAND", hl = "Command" },
  ["s"] = { name = "SELECT", hl = "Visual" },
}

local function get_mode()
  local m = vim.api.nvim_get_mode().mode
  local data = mode_map[m] or { name = string.upper(m), hl = "Normal" }

  return string.format(
    "%%#StatusLineMode%s#%%#StatusLineMode%sText# %s %%#StatusLineMode%s#%%*",
    data.hl, data.hl, data.name, data.hl
  )
end

local function get_git()
  local dict = vim.b.gitsigns_status_dict
  local branch = (dict and dict.head) or vim.b.gitsigns_head
  if not branch or branch == "" then return "" end

  local parts = { string.format("%%#StatusLineGit# %s%%*", branch) }

  if not dict then
    return table.concat(parts, " ")
  end

  local added = dict.added and dict.added > 0 and ("%#StatusLineGitAdded#+" .. dict.added .. "%*") or ""
  local changed = dict.changed and dict.changed > 0 and ("%#StatusLineGitChanged#~" .. dict.changed .. "%*") or ""
  local removed = dict.removed and dict.removed > 0 and ("%#StatusLineGitRemoved#-" .. dict.removed .. "%*") or ""

  if added ~= "" then parts[#parts + 1] = added end
  if changed ~= "" then parts[#parts + 1] = changed end
  if removed ~= "" then parts[#parts + 1] = removed end

  return table.concat(parts, " ")
end

local function get_diagnostics()
  if #vim.diagnostic.get(0) == 0 then return "" end

  local counts = {
    error = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }),
    warn = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN }),
    info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO }),
    hint = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT }),
  }

  local parts = {}
  if counts.error > 0 then table.insert(parts, "%#StatusLineDiagError#E" .. counts.error .. "%*") end
  if counts.warn > 0 then table.insert(parts, "%#StatusLineDiagWarn#W" .. counts.warn .. "%*") end
  if counts.info > 0 then table.insert(parts, "%#StatusLineDiagInfo#I" .. counts.info .. "%*") end
  if counts.hint > 0 then table.insert(parts, "%#StatusLineDiagHint#H" .. counts.hint .. "%*") end

  return table.concat(parts, " ")
end

local function get_lsp()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return "%#StatusLineLspInactive# No LSP%*"
  end

  local names = {}
  for _, client in ipairs(clients) do
    names[#names + 1] = client.name
  end

  return string.format("%%#StatusLineLspActive# [%s]%%*", table.concat(names, ", "))
end

local function get_progress()
  local status = vim.ui.progress_status()
  if type(status) ~= "string" or status == "" then
    return ""
  end
  return string.format("%%#StatusLineLspActive#◐ %s%%*", status)
end

local function get_filename()
  local filename = vim.fn.expand("%:t")
  if filename == "" then return "[No Name]" end

  local icon, icon_hl = icons.get("file", filename)

  local modified = vim.bo.modified and "[+]" or ""
  local readonly = vim.bo.readonly and "🔒" or ""

  return string.format(
    "%%#%s#%s%%* %%#StatusLineFile#%s%%* %%#ErrorMsg#%s%s%%*",
    icon_hl,
    icon,
    filename,
    modified,
    readonly
  )
end

function M.render()
  return table.concat({
    get_mode(),
    " ",
    get_filename(),
    " ",
    get_git(),
    "%=",
    get_diagnostics(),
    " ",
    get_lsp(),
    " ",
    get_progress(),
    " ",
    "%l:%c %P",
  })
end

return M
