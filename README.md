# nvim-mini

Minimal Neovim configuration focused on built-in LSP and a small set of plugins.

## Features

- Opinionated defaults for editor options.
- Built-in LSP configuration for Lua, Go, Rust, and Zig.
- Native LSP completion with `vim.lsp.completion` (no `nvim-cmp`).
- Lightweight plugin set (TokyoNight, LSP config, LazyDev, fzf-lua, notify, conform, gitsigns, fidget, mini.icons, mini.files, nvim-treesitter).
- Custom statusline with mode, git, diagnostics, and LSP client info.
- Keymaps for common editing, LSP actions, and file exploration.

## Requirements

- Neovim 0.12+ (for `vim.lsp`, `vim.pack`, and `vim.snippet`).
- Language servers installed locally (e.g. `lua-language-server`, `gopls`, `rust-analyzer`, `zls`).
- Formatters for conform.nvim (e.g. `stylua`, `gofumpt`, `rustfmt`, `zig fmt`) — install via your system package manager.

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

3. Plugins will be fetched via `vim.pack` on startup. Treesitter parsers are installed automatically shortly after.

## Layout

```
.
├── init.lua
└── lua
    └── devil
        ├── init.lua          # bootstrap: load all modules
        ├── base.lua          # core editor options
        ├── plug.lua          # plugin list, setup, and user commands
        ├── lsp.lua           # LSP server enable + completion + attach keymaps
        ├── servers.lua       # per-language server config + binary names
        ├── cmp.lua           # native completion keymaps and highlight
        ├── keymap.lua        # general + LSP keymaps
        ├── utils.lua         # keymap registration helpers
        ├── format.lua        # formatting abstraction (conform → LSP fallback)
        ├── conform.lua       # conform.nvim formatter config
        ├── diag.lua          # diagnostic display settings + toggle
        ├── picker.lua        # fzf-lua finder wrappers
        ├── notify.lua        # nvim-notify setup
        ├── statusline.lua    # custom statusline renderer
        ├── health.lua        # :DevilHealth checks
        ├── help.lua          # :KeymapHelp command
        ├── autocmds.lua      # autocommands (git, diagnostic, treesitter, format-on-save)
        └── local.example.lua # template for machine-specific overrides
```

## Notes

- **Treesitter**: Parsers are auto-installed on startup. Matching filetypes auto-start Treesitter highlighting via `vim.treesitter.start()`. Run `:TSInstallAll` to manually reinstall parsers.
- **File explorer**: `<M-m>` opens `mini.files` (Miller columns). Navigate with `h`/`l`, preview enabled.
- **Formatting**: `conform.nvim` is preferred; falls back to built-in LSP formatting. Install formatters separately (`stylua`, `gofumpt`, `rustfmt`, `zig`).
- **Icons**: `mini.icons` provides icons for completion, statusline, and `mini.files`. Requires a Nerd Font.
- To customize LSP settings, edit `lua/devil/servers.lua`.
- For machine-specific overrides, create `lua/devil/local.lua` (see `lua/devil/local.example.lua`).

## Maintenance Commands

- `:PackSync` install/sync plugins declared in `lua/devil/plug.lua`.
- `:TSInstallAll` install configured Treesitter parsers manually.
- `:DiagVirtualLinesToggle` toggle diagnostic virtual lines.
- `:KeymapHelp` open built-in keymap cheatsheet.
- `:DevilHealth` run quick environment/config checks.

## Keymaps

### General

- `<M-m>` open file explorer (`mini.files`).
- `<leader>ff` find files.
- `<leader>fg` live grep.
- `<leader>fb` switch buffers.
- `<leader>fh` search help tags.
- `<leader>fm` format buffer.
- `<leader>bn` new buffer.
- `<leader>ch` keymap cheatsheet.
- `<leader>dv` toggle diagnostic virtual lines.
- `<Esc>` clear search highlight.

### LSP (buffer-local)

- `gd` go to definition.
- `gr` find references.
- `gD` go to declaration.
- `gi` go to implementation.
- `K` hover documentation.
- `<leader>rn` rename symbol.
- `<leader>ca` code action.
- `[d` / `]d` prev/next diagnostic.
- `<leader>e` diagnostic float.

### File Explorer (mini.files)

- `h` / `l` go out / in directory.
- `H` / `L` go out / in and set as root.
- `q` close.
- `=` synchronize changes.

## First-Run Troubleshooting

- If plugins fail to download (`Could not resolve host: github.com`), verify network/proxy first,
  then rerun `:PackSync`.

- If running as isolated profile, always use:

  ```bash
  NVIM_APPNAME=nvim-mini nvim
  ```

- If a language server does not start, run `:DevilHealth` and confirm the corresponding executable
  is in your `PATH`.

- If file icons show as squares or question marks, your terminal font does not support Nerd Fonts.
  Switch to a Nerd Font (e.g. JetBrainsMono Nerd Font, FiraCode Nerd Font, Hack Nerd Font).
