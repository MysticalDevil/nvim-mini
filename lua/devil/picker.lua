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

M.references = with_fzf(function(fzf)
  fzf.lsp_references()
end)

M.symbols = with_fzf(function(fzf)
  fzf.lsp_document_symbols()
end)

return M
