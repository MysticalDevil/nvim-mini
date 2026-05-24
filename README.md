# nvim-mini

Minimal Neovim configuration focused on built-in LSP and a small set of plugins.

## Features

- Opinionated defaults for editor options.  
- Built-in LSP configuration for Lua, Go, Rust, and Zig.  
- Lightweight plugin set (Treesitter, TokyoNight, LSP config, LazyDev, fzf-lua, notify, conform, gitsigns, mini.icons).  
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
        ├── autocmds.lua    # global autocommands
        ├── base.lua        # core editor options
        ├── cmp.lua         # native completion setup
        ├── conform.lua     # formatter config (conform.nvim)
        ├── diag.lua        # diagnostic display config
        ├── format.lua      # format dispatcher (conform → LSP)
        ├── health.lua      # :DevilHealth command
        ├── help.lua        # :KeymapHelp command
        ├── init.lua        # module bootstrap
        ├── keymap.lua      # general + LSP keymaps
        ├── local.example.lua # template for host-specific overrides
        ├── lsp.lua         # LSP server setup + LspAttach keymaps
        ├── notify.lua      # nvim-notify config
        ├── picker.lua      # fzf-lua wrapper with fallbacks
        ├── plug.lua        # plugin list + config
        ├── servers.lua     # per-language server config
        ├── statusline.lua  # custom statusline
        └── utils.lua       # keymap / plugin helpers
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
- `:NetGet <url>` HTTP GET response into a scratch buffer.

## Finder Keymaps

- `<leader>ff` find files.
- `<leader>fg` live grep.
- `<leader>fb` switch buffers.
- `<leader>fh` search help tags.
- `<leader>fd` show document diagnostics.
- `<leader>fr` show LSP references.
- `<leader>fs` show document symbols.
- `<leader>fu` open built-in undotree.
- `<leader>fD` open built-in diff tool.

## First-Run Troubleshooting

- If plugins fail to download (`Could not resolve host: github.com`), verify network/proxy first,
  then rerun `:PackSync`.

- If running as isolated profile, always use:

  ```bash
  NVIM_APPNAME=nvim-mini nvim
  ```

- If a language server does not start, run `:DevilHealth` and confirm the corresponding executable
  is in your `PATH`.
