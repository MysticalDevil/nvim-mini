# nvim-mini

Minimal Neovim configuration focused on built-in LSP and a small set of plugins.

## Features

- Opinionated defaults for editor options.  
- Built-in LSP configuration for Lua, Go, Rust, and Zig.  
- Lightweight plugin set (Treesitter, Onedark, LSP config, LazyDev).  
- Keymaps for common editing and LSP actions.  

## Requirements

- Neovim 0.12+ (for `vim.lsp` and `vim.pack`).  
- Language servers installed locally (e.g. `lua-language-server`, `gopls`, `rust-analyzer`, `zls`).  

## Installation

1. Choose one install mode:

   ```bash
   # Mode A: Replace main Neovim config
   git clone <repo-url> ~/.config/nvim

   # Mode B: Keep as an isolated profile (recommended for this repo name)
   git clone <repo-url> ~/.config/nvim-mini
   ```

2. Launch Neovim:

   ```bash
   # Mode A
   nvim

   # Mode B
   NVIM_APPNAME=nvim-mini nvim
   ```

3. Plugins will be fetched via `vim.pack` on startup.

## Layout

```
.
├── init.lua
└── lua
    └── devil
        ├── base.lua        # core editor options
        ├── cmp.lua         # native completion keymaps
        ├── keymap.lua      # general + LSP keymaps
        ├── lsp.lua         # LSP setup + keymap binding
        ├── lsp
        │   └── servers.lua # per-language server config
        ├── plug.lua        # plugin list
        └── utils.lua       # keymap helpers
```

## Notes

- Treesitter is installed but not configured yet; add a `nvim-treesitter` setup block if you want
  language-specific highlighting and indentation.
- To customize LSP settings, edit `lua/devil/lsp/servers.lua`.
