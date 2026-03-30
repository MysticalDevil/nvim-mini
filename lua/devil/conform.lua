local M = {}

function M.setup()
  local ok, conform = pcall(require, "conform")
  if not ok then
    return
  end

  conform.setup({
    formatters_by_ft = {
      go = { "gofumpt" },
      lua = { "stylua" },
      rust = { "rustfmt" },
      zig = { "zigfmt" },
    },
    notify_on_error = true,
  })
end

return M
