local servers = require("devil.lsp.servers").servers

for server, config in pairs(servers) do
  -- Register per-server settings and enable built-in LSP clients.
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end

local km = require("devil.keymap")
local utils = require("devil.utils")
local cmp = require("devil.cmp")

vim.opt.completeopt = { "menuone", "noselect", "popup" }

utils.set_keymaps(cmp.mappings)

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    -- Enable LSP-driven completion when a client attaches.
    vim.lsp.completion.enable(true, client.id, bufnr, {
      autotrigger = true,
    })

    -- Apply buffer-local LSP keymaps.
    utils.apply(km.lsp, { buffer = bufnr })
  end,
})
