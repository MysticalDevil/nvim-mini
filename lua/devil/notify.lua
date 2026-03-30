local M = {}

function M.setup()
  local ok, notify = pcall(require, "notify")
  if not ok then
    return
  end

  notify.setup({
    fps = 30,
    render = "wrapped-default",
    stages = "fade_in_slide_out",
    timeout = 1800,
    top_down = false,
  })

  vim.notify = notify
end

return M
