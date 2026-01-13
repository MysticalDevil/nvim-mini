local M = {}

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

return M
