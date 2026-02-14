local M = {}

---@param opts? { bufnr?: integer, async?: boolean, timeout_ms?: integer }
function M.format(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local async = opts.async == true
  local timeout_ms = opts.timeout_ms or 3000

  local ok_conform, conform = pcall(require, "conform")
  if ok_conform and type(conform.format) == "function" then
    conform.format({
      bufnr = bufnr,
      async = async,
      timeout_ms = timeout_ms,
      lsp_fallback = true,
    })
    return
  end

  vim.lsp.buf.format({
    bufnr = bufnr,
    async = async,
    timeout_ms = timeout_ms,
  })
end

return M
