--- Utility helpers for reusable keymap registration.
-- @module devil.utils

local M = {}

--- Register keymaps from a declarative mapping list.
-- Each item supports: `mode`, `lhs`, `rhs`, optional `desc`, optional `opts`.
-- If `opts.silent` is omitted, it defaults to `true`.
-- @param mappings table[] mapping definitions
function M.set_keymaps(mappings)
  for _, map in ipairs(mappings) do
    local mode = map.mode
    local lhs = map.lhs
    local rhs = map.rhs
    local opts = map.opts or {}

    if map.desc then
      opts.desc = map.desc
    end

    if opts.silent == nil then
      opts.silent = true
    end

    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

--- Apply a mapping list with additional options merged into each mapping.
-- Useful for buffer-local LSP mappings (`{ buffer = bufnr }`), etc.
-- @param mappings table[] mapping definitions
-- @param extra_opts table|nil options merged into each `map.opts`
function M.apply(mappings, extra_opts)
  if not extra_opts then
    return M.set_keymaps(mappings)
  end

  local merged = {}
  for _, map in ipairs(mappings) do
    local new = vim.tbl_deep_extend("force", {}, map)
    new.opts = vim.tbl_deep_extend("force", {}, map.opts or {}, extra_opts)
    table.insert(merged, new)
  end

  M.set_keymaps(merged)
end

---@param plugins string[]
function M.plug_add(plugins)
  local normalized = {}
  for _, p in ipairs(plugins) do
    if not p:match("^https?://") then
      table.insert(normalized, "https://github.com/" .. p)
    else
      table.insert(normalized, p)
    end
  end
  vim.pack.add(normalized)
end

return M
