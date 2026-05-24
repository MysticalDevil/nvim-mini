local formatter = require("devil.format")

local stl_augroup = vim.api.nvim_create_augroup("StatuslineGit", { clear = true })

vim.api.nvim_create_autocmd("User", {
  group = stl_augroup,
  pattern = "GitSignsUpdate",
  callback = function()
    vim.cmd("redrawstatus")
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
  group = stl_augroup,
  callback = function()
    vim.cmd("redrawstatus")
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = stl_augroup,
  callback = function(args)
    local bt = vim.bo[args.buf].buftype
    if bt ~= "" then
      return
    end

    if vim.b[args.buf].gitsigns_attached then
      return
    end

    local ok, gs = pcall(require, "gitsigns")
    if not ok then
      return
    end

    pcall(gs.attach, args.buf)
  end,
})

local diag_augroup = vim.api.nvim_create_augroup("diagnostic_tweaks", { clear = true })

-- Cache the default virtual_text configuration.
-- Note: This assumes you generally want virtual_text enabled globally.
---@type boolean|vim.diagnostic.Opts.VirtualText|fun(namespace: integer, bufnr:integer)
local default_virt_text = vim.diagnostic.config().virtual_text

-- State table to track virtual_text hidden status per buffer.
---@type table<integer, boolean>
local virt_text_hidden_by_buf = {}

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "DiagnosticChanged" }, {
  group = diag_augroup,
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local is_virt_text_hidden = virt_text_hidden_by_buf[bufnr] == true

    -- Get current line number (0-indexed for vim.diagnostic.get)
    ---@type integer
    local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1

    -- Get diagnostics for the current line
    ---@type vim.Diagnostic[]
    local diagnostics = vim.diagnostic.get(bufnr, { lnum = lnum })

    ---@type boolean
    local has_diagnostic = not vim.tbl_isempty(diagnostics)

    -- State machine logic: Only update config if the state actually changes.
    -- This significantly reduces API calls and redraw overhead.
    if has_diagnostic and not is_virt_text_hidden then
      -- Diagnostics exist on current line + virtual_text is visible -> Hide it
      vim.diagnostic.show(nil, bufnr, nil, { virtual_text = false })
      virt_text_hidden_by_buf[bufnr] = true
    elseif not has_diagnostic and is_virt_text_hidden then
      -- No diagnostics on current line + virtual_text is hidden -> Restore it
      vim.diagnostic.show(nil, bufnr, nil, { virtual_text = default_virt_text })
      virt_text_hidden_by_buf[bufnr] = false
    end
  end,
})

-- Force a diagnostic redraw when exiting Insert mode.
-- Essential when 'update_in_insert = false' is set, ensuring
-- virtual_lines appear immediately upon entering Normal mode.
vim.api.nvim_create_autocmd("InsertLeave", {
  group = diag_augroup,
  callback = function()
    vim.diagnostic.show(nil, 0)
  end,
})

local ts_augroup = vim.api.nvim_create_augroup("treesitter_augroup", { clear = true })
local ts_missing_notified = {}
vim.api.nvim_create_autocmd("FileType", {
  group = ts_augroup,
  pattern = { "c", "lua", "rust", "zig", "go" },
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local ok = pcall(vim.treesitter.start, args.buf)
    if not ok then
      if not ts_missing_notified[ft] then
        ts_missing_notified[ft] = true
        vim.notify(
          string.format("[treesitter] parser for `%s` is not installed; skipping TS features", ft),
          vim.log.levels.WARN
        )
      end
      return
    end

    local has_ts, _ = pcall(require, "nvim-treesitter")
    if has_ts then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

local lsp_augroup = vim.api.nvim_create_augroup("lsp_augroup", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = lsp_augroup,
  pattern = "*",
  callback = function(args)
    local bufnr = args.buf
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    if vim.bo[bufnr].buftype ~= "" then
      return
    end
    if not vim.bo[bufnr].modifiable then
      return
    end
    if vim.api.nvim_buf_get_name(bufnr) == "" then
      return
    end

    formatter.format({ bufnr = args.buf, async = false })
  end,
})
