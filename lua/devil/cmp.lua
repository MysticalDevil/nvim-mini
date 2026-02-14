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
    rhs = "<C-e>",
    desc = "Abort completion",
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

local function apply_completion_hl()
  vim.api.nvim_set_hl(0, "Pmenu", { link = "NormalFloat" })
  vim.api.nvim_set_hl(0, "PmenuSel", { link = "Visual" })

  vim.api.nvim_set_hl(0, "PmenuMatch", { link = "Search" })
  vim.api.nvim_set_hl(0, "PmenuMatchSel", { link = "IncSearch" })

  vim.api.nvim_set_hl(0, "PmenuSbar", { link = "Pmenu" })
  vim.api.nvim_set_hl(0, "PmenuThumb", { link = "PmenuSel" })

  vim.api.nvim_set_hl(0, "PmenuKind", { link = "Special" })

  vim.api.nvim_set_hl(0, "CmpItemKindText", { link = "@string" })
  vim.api.nvim_set_hl(0, "CmpItemKindMethod", { link = "@function.method" })
  vim.api.nvim_set_hl(0, "CmpItemKindFunction", { link = "@function" })
  vim.api.nvim_set_hl(0, "CmpItemKindConstructor", { link = "@constructor" })
  vim.api.nvim_set_hl(0, "CmpItemKindField", { link = "@variable.member" })
  vim.api.nvim_set_hl(0, "CmpItemKindVariable", { link = "@variable" })
  vim.api.nvim_set_hl(0, "CmpItemKindClass", { link = "@type" })
  vim.api.nvim_set_hl(0, "CmpItemKindInterface", { link = "@type" })
  vim.api.nvim_set_hl(0, "CmpItemKindModule", { link = "@module" })
  vim.api.nvim_set_hl(0, "CmpItemKindProperty", { link = "@property" })
  vim.api.nvim_set_hl(0, "CmpItemKindUnit", { link = "@constant" })
  vim.api.nvim_set_hl(0, "CmpItemKindValue", { link = "@constant" })
  vim.api.nvim_set_hl(0, "CmpItemKindEnum", { link = "@type" })
  vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { link = "@keyword" })
  vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { link = "Special" })
  vim.api.nvim_set_hl(0, "CmpItemKindColor", { link = "Special" })
  vim.api.nvim_set_hl(0, "CmpItemKindFile", { link = "Directory" })
  vim.api.nvim_set_hl(0, "CmpItemKindReference", { link = "@variable" })
  vim.api.nvim_set_hl(0, "CmpItemKindFolder", { link = "Directory" })
  vim.api.nvim_set_hl(0, "CmpItemKindEnumMember", { link = "@constant" })
  vim.api.nvim_set_hl(0, "CmpItemKindConstant", { link = "@constant" })
  vim.api.nvim_set_hl(0, "CmpItemKindStruct", { link = "@type" })
  vim.api.nvim_set_hl(0, "CmpItemKindEvent", { link = "Special" })
  vim.api.nvim_set_hl(0, "CmpItemKindOperator", { link = "@operator" })
  vim.api.nvim_set_hl(0, "CmpItemKindTypeParameter", { link = "@type" })
end

local function setup_completion_hl_autocmd()
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = apply_completion_hl,
  })
  apply_completion_hl()
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
    local is_file_kind = (kind_id == 17 or kind_id == 19)

    if is_file_kind or looks_like_path then
      item.label = shorten_middle(relpath(label), max_file_len)
    end

    return item
  end
end

local function setup_native_completion()
  local max_file_len = 48
  local item_preprocess = make_item_preprocess(max_file_len)

  local function kind_hlgroup(kind_id)
    local kind_name = kind_names[kind_id]
    if not kind_name then return nil, nil end
    return "CmpItemKind" .. kind_name, kind_name
  end

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then return end

      vim.lsp.completion.enable(true, client.id, bufnr, {
        autotrigger = true,
        item_preprocess = item_preprocess,

        convert = function(item)
          local out = {
            word = item.insertText or item.label,
            abbr = item.label,
            menu = "",
            kind = "",
          }

          local hl, kind_name = kind_hlgroup(item.kind)
          if kind_name then
            local icon = select(1, icons.get("lsp", kind_name))
            out.kind = icon .. " " .. kind_name
            out.kind_hlgroup = hl
          end

          return out
        end,
      })
    end,
  })
end

function M.setup()
  setup_completeopt()
  setup_completion_hl_autocmd()
  setup_native_completion()
  utils.set_keymaps(M.mappings)
end
return M
