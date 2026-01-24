local M = {}

local servers = require("devil.servers").servers
local km = require("devil.keymap")
local utils = require("devil.utils")
local cmp = require("devil.cmp")

function M.setup()
  for server, config in pairs(servers) do
    vim.lsp.config(server, config)
    vim.lsp.enable(server)
  end

  cmp.setup()

  vim.api.nvim_create_autocmd("LspAttach", {
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
