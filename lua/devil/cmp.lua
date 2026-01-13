local M = {}

local function pumvisible()
  return vim.fn.pumvisible() == 1
end

local function snippet_jumpable(dir)
  if not vim.snippet or not vim.snippet.active then
    return false
  end

  local ok, active = pcall(vim.snippet.active, { direction = dir })
  if ok and active then return true end

  ok, active = pcall(vim.snippet.active, { jump_dir = dir })
  if ok and active then return true end

  ok, active = pcall(vim.snippet.active)
  return ok and active or false
end

M.mappings = {
  {
    mode = "i",
    lhs = "<C-Space>",
    rhs = function() vim.lsp.completion.get() end,
    desc = "LSP completion (native)",
  },

  {
    mode = "i",
    lhs = "<CR>",
    rhs = function()
      return pumvisible() and "<C-y>" or "<CR>"
    end,
    desc = "Confirm completion / Enter",
    opts = { expr = true, replace_keycodes = true },
  },

  {
    mode = "i",
    lhs = "<C-e>",
    rhs = function()
      return pumvisible() and "<C-e>" or "<C-e>"
    end,
    desc = "Abort completion",
    opts = { expr = true, replace_keycodes = true },
  },

  {
    mode = { "i", "s" },
    lhs = "<Tab>",
    rhs = function()
      if pumvisible() then
        return "<C-n>"
      end
      if snippet_jumpable(1) then
        vim.snippet.jump({ direction = 1 })
        return ""
      end
      return "<Tab>"
    end,
    desc = "Next item / snippet jump / Tab",
    opts = { expr = true, replace_keycodes = true },
  },

  {
    mode = { "i", "s" },
    lhs = "<S-Tab>",
    rhs = function()
      if pumvisible() then
        return "<C-p>"
      end
      if snippet_jumpable(-1) then
        vim.snippet.jump({ direction = -1 })
        return ""
      end
      return "<S-Tab>"
    end,
    desc = "Prev item / snippet jump",
    opts = { expr = true, replace_keycodes = true },
  },

  {
    mode = "i",
    lhs = "<C-n>",
    rhs = function()
      if pumvisible() then return "<C-n>" end
      vim.lsp.completion.get()
      return ""
    end,
    desc = "Trigger/select next completion",
    opts = { expr = true, replace_keycodes = true },
  },

  {
    mode = "i",
    lhs = "<C-p>",
    rhs = function()
      if pumvisible() then return "<C-p>" end
      vim.lsp.completion.get()
      return ""
    end,
    desc = "Trigger/select prev completion",
    opts = { expr = true, replace_keycodes = true },
  },
}

return M

