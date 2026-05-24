local M = {}

local servers = require("devil.servers").servers
local km = require("devil.keymap")
local utils = require("devil.utils")
local cmp = require("devil.cmp")

---Fallback executable names for known language servers.
---@type table<string, string>
local server_binaries = {
  lua_ls = "lua-language-server",
  gopls = "gopls",
  rust_analyzer = "rust-analyzer",
  zls = "zls",
}

---Resolve executable path for a server.
---@param server string
---@param config table
---@return string
local function resolve_server_bin(server, config)
  if type(config.cmd) == "table" and type(config.cmd[1]) == "string" and config.cmd[1] ~= "" then
    return config.cmd[1]
  end
  return server_binaries[server] or server
end

local function setup_lsp_progress_echo()
  local group = vim.api.nvim_create_augroup("DevilLspProgress", { clear = true })

  vim.api.nvim_create_autocmd("LspProgress", {
    group = group,
    callback = function(ev)
      local params = ev.data and ev.data.params
      local value = params and params.value
      if not value then
        return
      end

      vim.api.nvim_echo({ { value.message or "done" } }, false, {
        id = "lsp." .. tostring(ev.data.client_id),
        kind = "progress",
        source = "vim.lsp",
        title = value.title,
        status = value.kind ~= "end" and "running" or "success",
        percent = value.percentage,
      })
    end,
    desc = "Render LSP progress in native progress area",
  })
end

---Configure and enable LSP servers, completion, and LspAttach keymaps.
function M.setup()
  for server, config in pairs(servers) do
    local bin = resolve_server_bin(server, config)
    if vim.fn.executable(bin) ~= 1 then
      vim.notify(string.format("[lsp] %s skipped: executable `%s` not found in PATH", server, bin), vim.log.levels.WARN)
      goto continue
    end

    vim.lsp.config(server, config)
    vim.lsp.enable(server)
    ::continue::
  end

  setup_lsp_progress_echo()
  cmp.setup()

  local lsp_attach_group = vim.api.nvim_create_augroup("DevilLspAttachKeymaps", { clear = true })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = lsp_attach_group,
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then
        return
      end

      utils.apply(km.lsp, { buffer = bufnr })
    end,
  })
end

return M
