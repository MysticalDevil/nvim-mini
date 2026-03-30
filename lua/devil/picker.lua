local M = {}

local function with_fzf(fn)
  return function(...)
    local ok, fzf = pcall(require, "fzf-lua")
    if not ok then
      vim.notify("fzf-lua is not available yet; run :PackSync and restart Neovim", vim.log.levels.WARN)
      return
    end
    return fn(fzf, ...)
  end
end

local function with_fzf_lsp(method, fallback)
  return with_fzf(function(fzf)
    local picker = fzf[method]
    if type(picker) == "function" then
      return picker()
    end

    if fallback then
      return fallback()
    end

    vim.notify(string.format("fzf-lua does not support `%s` in this build", method), vim.log.levels.WARN)
  end)
end

M.files = with_fzf(function(fzf)
  fzf.files()
end)

M.grep = with_fzf(function(fzf)
  fzf.live_grep()
end)

M.buffers = with_fzf(function(fzf)
  fzf.buffers()
end)

M.help = with_fzf(function(fzf)
  fzf.helptags()
end)

M.diagnostics = with_fzf(function(fzf)
  fzf.diagnostics_document()
end)

M.definitions = with_fzf_lsp("lsp_definitions", vim.lsp.buf.definition)

M.declarations = with_fzf_lsp("lsp_declarations", vim.lsp.buf.declaration)

M.implementations = with_fzf_lsp("lsp_implementations", vim.lsp.buf.implementation)

M.references = with_fzf_lsp("lsp_references", vim.lsp.buf.references)

M.symbols = with_fzf_lsp("lsp_document_symbols")

return M
