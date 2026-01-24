local M = {}

local utils = require("devil.utils")
local icons = require("mini.icons")

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
    rhs = function() return pumvisible() and "<C-y>" or "<CR>" end,
    desc = "Confirm completion / Enter",
    opts = { expr = true, replace_keycodes = true },
  },
  {
    mode = "i",
    lhs = "<C-e>",
    rhs = function() return pumvisible() and "<C-e>" or "<C-e>" end,
    desc = "Abort completion",
    opts = { expr = true, replace_keycodes = true },
  },
  {
    mode = { "i", "s" },
    lhs = "<Tab>",
    rhs = function()
      if pumvisible() then return "<C-n>" end
      if snippet_jumpable(1) then
        vim.snippet.jump(1)
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
      if pumvisible() then return "<C-p>" end
      if snippet_jumpable(-1) then
        vim.snippet.jump(-1)
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

local function set_pum_hl()
  local function apply()
    vim.api.nvim_set_hl(0, "Pmenu", { link = "NormalFloat", force = true })
    vim.api.nvim_set_hl(0, "PmenuSel", { link = "Visual", force = true })

    local kind_links = {
      PmenuKindText = "String",
      PmenuKindMethod = "Function",
      PmenuKindFunction = "Function",
      PmenuKindConstructor = "Type",
      PmenuKindField = "Identifier",
      PmenuKindVariable = "Identifier",
      PmenuKindClass = "Type",
      PmenuKindInterface = "Type",
      PmenuKindModule = "Include",
      PmenuKindProperty = "Identifier",
      PmenuKindUnit = "Number",
      PmenuKindValue = "String",
      PmenuKindEnum = "Type",
      PmenuKindKeyword = "Keyword",
      PmenuKindSnippet = "Special",
      PmenuKindColor = "Special",
      PmenuKindFile = "Directory",
      PmenuKindReference = "Special",
      PmenuKindFolder = "Directory",
      PmenuKindEnumMember = "Constant",
      PmenuKindConstant = "Constant",
      PmenuKindStruct = "Type",
      PmenuKindEvent = "Type",
      PmenuKindOperator = "Operator",
      PmenuKindTypeParameter = "Type",
    }

    for kind_hl, target_hl in pairs(kind_links) do
      vim.api.nvim_set_hl(0, kind_hl, { link = target_hl, force = true })
    end
  end

  apply()
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = apply,
  })
end

local function setup_completeopt()
  vim.opt.completeopt = { "menuone", "noselect", "popup" }
end

local function shorten_middle(s, maxlen)
  if not s then return "" end
  if #s <= maxlen then return s end
  if maxlen <= 5 then return s:sub(1, maxlen) end
  local head = math.floor((maxlen - 1) * 0.6)
  local tail = (maxlen - 1) - head
  return s:sub(1, head) .. "…" .. s:sub(#s - tail + 1)
end

local function relpath(p)
  if not p or p == "" then return p end
  local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":p")
  local rp = vim.fn.fnamemodify(p, ":p")
  if rp:sub(1, #cwd) == cwd then
    local out = rp:sub(#cwd + 1)
    if out:sub(1, 1) == "/" then out = out:sub(2) end
    return out
  end
  return vim.fn.fnamemodify(p, ":~")
end

local kind_names = {}
for k, v in pairs(vim.lsp.protocol.CompletionItemKind) do
  if type(k) == "string" then kind_names[v] = k end
end

local function make_item_preprocess(max_file_len)
  return function(item)
    local kind_id = item.kind
    local label = item.label
    local looks_like_path = type(label) == "string" and (label:find("/") or label:find("\\"))
    local is_file_kind = (kind_id == 17 or kind_id == 19) -- File or Folder

    if is_file_kind or looks_like_path then
      item.label = shorten_middle(relpath(label), max_file_len)
    end

    local kind_name = kind_names[kind_id]
    if kind_name then
      local icon, _ = icons.get("lsp", kind_name)
      item.kind = icon .. " " .. kind_name
    end

    return item
  end
end

local function setup_native_completion()
  local max_file_len = 48
  local item_preprocess = make_item_preprocess(max_file_len)

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then return end

      vim.lsp.completion.enable(true, client.id, bufnr, {
        autotrigger = true,
        item_preprocess = item_preprocess,
      })
    end,
  })
end

function M.setup()
  setup_completeopt()
  set_pum_hl()
  setup_native_completion()
  utils.set_keymaps(M.mappings)
end

return M
