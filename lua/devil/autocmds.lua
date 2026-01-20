local aug = vim.api.nvim_create_augroup("StatuslineGit", { clear = true })

vim.api.nvim_create_autocmd("User", {
  group = aug,
  pattern = "GitSignsUpdate",
  callback = function()
    vim.cmd("redrawstatus")
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
  group = aug,
  callback = function()
    vim.cmd("redrawstatus")
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = aug,
  callback = function(args)
    local bt = vim.bo[args.buf].buftype
    if bt ~= "" then return end

    if vim.b[args.buf].gitsigns_attached then return end

    local ok, gs = pcall(require, "gitsigns")
    if not ok then return end

    pcall(gs.attach, args.buf)
  end,
})
