require("devil.base")
require("devil.plug")
require("devil.lsp")
require("devil.diag")

local utils = require("devil.utils")
utils.set_keymaps(require("devil.keymap").general)

require("devil.autocmds")

vim.opt.statusline = "%!v:lua.require('devil.statusline').render()"
