# nvim-mini

Minimal Neovim configuration focused on built-in LSP and a small set of plugins.

## Features

- Opinionated defaults for editor options.  
- Built-in LSP configuration for Lua, Go, Rust, and Zig.  
- Lightweight plugin set (Treesitter, TokyoNight, LSP config, LazyDev).  
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
        ├── servers.lua     # per-language server config
        ├── plug.lua        # plugin list
        └── utils.lua       # keymap helpers
```

## Notes

- Treesitter parsers are managed by `:TSInstallAll`; matching filetypes auto-start Treesitter and
  use Treesitter-based indentation.
- To customize LSP settings, edit `lua/devil/servers.lua`.
- For machine-specific overrides, create `lua/devil/local.lua` (see `lua/devil/local.example.lua`).

## Maintenance Commands

- `:PackSync` install/sync plugins declared in `lua/devil/plug.lua`.
- `:TSInstallAll` install configured Treesitter parsers.
- `:DiagVirtualLinesToggle` toggle diagnostic virtual lines.
- `:KeymapHelp` open built-in keymap cheatsheet.
- `:DevilHealth` run quick environment/config checks.

## First-Run Troubleshooting

- If `mise` reports untrusted config, run:

  ```bash
  mise trust ~/.config/nvim-mini/mise.toml
  ```

- If plugins fail to download (`Could not resolve host: github.com`), verify network/proxy first,
  then rerun `:PackSync`.

- If running as isolated profile, always use:

  ```bash
  NVIM_APPNAME=nvim-mini nvim
  ```

- If a language server does not start, run `:DevilHealth` and confirm the corresponding executable
  is in your `PATH`.
