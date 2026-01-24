require("devil.base").setup()
require("devil.plug").setup()
require("devil.lsp").setup()
require("devil.diag").setup()

local utils = require("devil.utils")
utils.set_keymaps(require("devil.keymap").general)

require("devil.autocmds")

vim.opt.statusline = "%!v:lua.require('devil.statusline').render()"
