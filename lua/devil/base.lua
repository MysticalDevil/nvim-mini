local options = {
  backup = false, -- create a backup file
  clipboard = "unnamedplus", -- allows neovim to access the system clipboard
  cmdheight = 0,
  completeopt = { "menu", "menuone", "noselect", "nearest" }, -- mostly just for cmp
  conceallevel = 0, -- so that `` is visiable in markdown files
  fileencoding = "utf-8", -- the encoding written to a file
  hlsearch = true, -- highlight all matches on previous search pattern
  ignorecase = true, -- ignore case in search patterns
  mouse = "a", -- allow the mouse to be used in neovim
  mousemoveevent = false, -- avoid excessive CursorMoved events on mouse movement
  pumheight = 10, -- pop up menu height
  showmode = false, -- we don't need to see things like -- INSERT -- anymore
  showtabline = 1, -- always show tabs
  smartcase = true, -- smart case
  smartindent = true, -- make indenting smarter again
  splitbelow = true, -- force all horizontal splits to go below current window
  splitright = true, -- force all vertical splits to go the right of current window
  swapfile = false, -- creates a swapfile
  background = "dark", -- background style
  termguicolors = true, -- set term gui colors
  timeoutlen = 300, -- time to wait for a mapped sequence to complete (in milliseconds)
  undofile = true, -- enable persistent undo
  updatetime = 300, -- faster completion (4000ms default)
  writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
  expandtab = true, -- convert tabs to spaces
  shiftwidth = 2, -- the number of spaces inserted for each indentation
  tabstop = 2, -- insert 2 spaces for a tab
  cursorline = true, -- highlight the current line
  number = true, -- set numbered lines
  relativenumber = false, -- set relative numbered lines
  numberwidth = 4, -- set number column width to 4 (default 4)
  colorcolumn = "120", -- the reference line on the right indicates the recommended length of code
  wildmenu = true,

  pumborder = "rounded",
  pummaxwidth = 40,
  autocomplete = true,
  complete = ".^5,t^3,w",

  signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
  wrap = false, -- display lines as one long line
  linebreak = true, -- companion to wrap, don't split words
  scrolloff = 8, -- minimal number if screen lines to keep above and below the cursor
  sidescrolloff = 8, -- minimal number of screen columns either of cursor if wrap is `false`
  guifont = "Fira Code,Noto Color Emoji,FiraCode Nerd Font,Hack Nerd Font:h12", -- the font used in graphical neovim applications
  whichwrap = "bs<>[]hl", -- which "horizontal" keys are allowed to travel to prev/next line

  -- fold
  foldlevel = 99,
  foldcolumn = "1",
  foldlevelstart = 99,
  foldenable = true,
}

local M = {}

local function setup_net_get_command()
  vim.api.nvim_create_user_command("NetGet", function(cmd)
    local url = cmd.args
    vim.net.request(url, {}, function(err, response)
      if err then
        vim.schedule(function()
          vim.notify("NetGet failed: " .. tostring(err), vim.log.levels.ERROR)
        end)
        return
      end

      local body = response and response.body or ""
      vim.schedule(function()
        local buf = vim.api.nvim_create_buf(true, true)
        local lines = vim.split(body, "\n", { plain = true })
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].bufhidden = "wipe"
        vim.bo[buf].modifiable = false
        local is_json = pcall(vim.json.decode, body)
        vim.bo[buf].filetype = is_json and "json" or "text"
        vim.api.nvim_buf_set_name(buf, "net://" .. url)
        vim.api.nvim_set_current_buf(buf)
      end)
    end)
  end, { desc = "HTTP GET into scratch buffer", nargs = 1 })
end

function M.setup()
  for k, v in pairs(options) do
    vim.opt[k] = v
  end

  vim.opt.shortmess:append("cilmnrx") -- shorten vim messages, see :help 'shortmess'
  vim.opt.iskeyword:append("-") -- hyphenated words recognized by searches
  vim.opt.formatoptions:remove({ "c", "r", "o" }) -- don't insert the current comment leader automatically for auto-wrapping comments using 'textwidth', hitting <Enter> in insert mode, or hitting 'o' or 'O' in normal mode.
  vim.opt.runtimepath:remove("/usr/share/vim/vimfiles") -- separate vim plugins from neovim in case vim still in use

  vim.g.encoding = "UTF-8"
  vim.loader.enable() -- improve startup time for neovim
  setup_net_get_command()
end

return M
