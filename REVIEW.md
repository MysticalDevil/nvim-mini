# nvim-mini 配置全面 Review

> 审查日期：2026-05-24

---

## 一、架构概览

```
init.lua          → require("devil")
lua/devil/init.lua → 按顺序加载各模块
  ├── base.lua      # 编辑器核心选项 + NetGet 命令 + UI2 实验性开关
  ├── plug.lua      # vim.pack 插件管理 + 插件配置 + colorscheme
  ├── lsp.lua       # LSP server 启动 + LspAttach keymaps
  ├── diag.lua      # 诊断显示配置 + virtual_lines 切换
  ├── help.lua      # KeymapHelp 命令（键位速查表）
  ├── health.lua    # DevilHealth 环境检查
  ├── local.lua     # (可选) 机器级覆盖，通过 pcall 加载
  ├── autocmds.lua  # 全局 autocmd（GitSigns、诊断、Treesitter、自动格式化）
  ├── cmp.lua       # 原生 vim.lsp.completion 配置 + 补全高亮
  ├── keymap.lua    # 声明式键位映射表（general + lsp）
  ├── utils.lua     # set_keymaps / apply / plug_add 工具函数
  ├── picker.lua    # fzf-lua 封装，带 graceful fallback
  ├── format.lua    # 格式化入口（conform → LSP fallback）
  ├── conform.lua   # conform.nvim 按文件类型配置
  ├── notify.lua    # nvim-notify 设置
  └── statusline.lua # 自定义状态栏渲染
```

整体结构清晰，模块职责分明，遵循"声明式配置 + 工具函数"的模式。

---

## 二、🐛 已发现 Bug

### 2.1 `<leader>fm` 键位重复定义（keymap.lua）

**位置**：`lua/devil/keymap.lua`

- `M.general` 第 ~60 行定义：`<leader>fm` → `formatter.format({ async = true })`
- `M.lsp` 第 ~28 行定义：`<leader>fm` → `formatter.format({ async = true })`

两处映射完全相同的功能，但：
- `M.general` 的映射通过 `utils.set_keymaps` 注册为**全局映射**
- `M.lsp` 的映射通过 `utils.apply(km.lsp, { buffer = bufnr })` 注册为**buffer-local 映射**

**影响**：当 LSP 附着到 buffer 时，buffer-local 映射会覆盖全局映射。当前行为一致（都是格式化），没有功能性 bug，但属于**冗余代码**，容易在后续改动中导致不一致。

**建议**：删除其中一个。推荐保留 `M.general` 中的定义，从 `M.lsp` 中移除。

---

### 2.2 `User GitSignsUpdate` autocmd 重复定义

**位置**：
- `lua/devil/statusline.lua` 第 ~105 行
- `lua/devil/autocmds.lua` 第 ~8 行

两处都在 `User GitSignsUpdate` 事件时调用 `vim.cmd("redrawstatus")`。

**影响**：每次 GitSigns 更新时 `redrawstatus` 被调用两次，轻微性能浪费。

**建议**：保留 `autocmds.lua` 中的版本（集中管理 autocmd），删除 `statusline.lua` 中的版本。

---

### 2.3 `get_diagnostics()` 重复调用 `vim.diagnostic.get`（statusline.lua）

**位置**：`lua/devil/statusline.lua` `get_diagnostics()` 函数

```lua
-- 第1次调用：判空检查
if #vim.diagnostic.get(0) == 0 then return "" end

-- 第2-5次调用：各 severity 计数
error = #vim.diagnostic.get(0, { severity = ... })
warn  = #vim.diagnostic.get(0, { severity = ... })
info  = #vim.diagnostic.get(0, { severity = ... })
hint  = #vim.diagnostic.get(0, { severity = ... })
```

**影响**：每次 statusline 刷新时调用 5 次 `vim.diagnostic.get`，而这是一个 O(n) 操作（需要遍历所有诊断）。

**建议**：调用一次并缓存结果：

```lua
local all = vim.diagnostic.get(0)
if #all == 0 then return "" end
-- 然后手动计数
```

---

## 三、⚡ 性能问题

### 3.1 `mousemoveevent = true` 开销过大

**位置**：`lua/devil/base.lua` 第 ~10 行

```lua
mousemoveevent = true,
```

这会使 Neovim 在**每次鼠标移动**时触发 `CursorMoved` 事件。结合 `autocmds.lua` 中的 `CursorMoved` 诊断 autocommand 和 `mousemoveevent`，会在鼠标悬停时产生大量不必要的 API 调用。

**建议**：除非确实需要鼠标 hover 功能，否则设为 `false`。如果是为了 LSP hover，可以通过 `<leader>e` 或 `K` 手动触发。

---

### 3.2 状态栏 `render()` 每次刷新都执行完整计算

**位置**：`lua/devil/statusline.lua`

```lua
vim.opt.statusline = "%!v:lua.require('devil.statusline').render()"
```

`render()` 在每次状态栏刷新时被调用（极其频繁），内部执行：
- `vim.api.nvim_get_hl()` 多次
- `vim.lsp.get_clients({ bufnr = 0 })`
- `vim.diagnostic.get()` × 5（见 2.3）
- `vim.ui.progress_status()`

**建议**：
1. 将模式名称映射、HL 颜色等**静态数据**移到模块顶层，避免每次渲染时重建
2. 使用 `vim.b` 变量缓存 buffer 级别的诊断/LSP 信息，通过 autocmd 更新
3. 对诊断计数使用 throttle/debounce 策略

---

### 3.3 `CursorMoved` + 诊断虚拟文本切换的频繁 `vim.diagnostic.show` 调用

**位置**：`lua/devil/autocmds.lua` 诊断 autocmd

```lua
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "DiagnosticChanged" }, {
  callback = function() ... vim.diagnostic.show(...) end
})
```

这个设计思路很好（光标在诊断行上时隐藏 virtual_text，移走后恢复），但：
- `CursorMoved` 触发频率极高
- `vim.diagnostic.show` 是一个有开销的 API 调用
- 配合 `mousemoveevent = true` 时，鼠标移动也会触发

**当前实现有状态机 guard**，仅在状态变化时调用，这是一个正确的优化。但仍需关注高频事件本身。

**建议**：考虑添加一个极小的 debounce（如 50ms），或使用 `vim.schedule` 包裹回调。

---

## 四、🔧 设计问题

### 4.1 使用了 Neovim 私有 API

**位置**：`lua/devil/base.lua` `enable_ui2()`

```lua
local ok, ui2 = pcall(require, "vim._core.ui2")
```

`vim._core.ui2` 以下划线前缀命名，是 Neovim 内部私有 API，不保证跨版本兼容。

**影响**：Neovim 升级时可能直接崩溃或行为异常。

**建议**：移除或改为 feature-flag 检查。判断是否真的需要此功能——如果只是调整消息窗口高度，可以用 `cmdheight` 和 `vim.o.cmdheight` 替代。

---

### 4.2 两个 colorscheme 在 lock 文件中但只用一个

**位置**：`nvim-pack-lock.json`

- `tokyonight.nvim` ✅（在 `plug.lua` 中使用）
- `onedarkpro.nvim` ❌（未在代码中引用）

**建议**：运行 `:PackSync` 清理未使用插件，或从 lock 文件中移除 `onedarkpro.nvim`。同样，`fidget.nvim` 也被注释掉但留在 lock 文件中。

---

### 4.3 `plug_install()` 每次 `PackSync` 无条件调用 `vim.pack.add`

**位置**：`lua/devil/plug.lua`

```lua
local function plug_install()
  utils.plug_add({ "nvim-treesitter/...", ... })
end
```

`PackSync` 自定义命令每次调用 `plug_install()`，而 `plug_install` 每次都会调用 `vim.pack.add()`，没有检查插件是否已安装。

**影响**：虽然 `vim.pack.add` 内部可能有幂等检查，但依赖隐式行为不够安全。

**建议**：添加简单的 installed-check，或依赖 `vim.pack` 的锁文件机制。

---

### 4.4 Treesitter parser install API 可能不稳定

**位置**：`lua/devil/plug.lua` `install_treesitter_parsers()`

```lua
require("nvim-treesitter").install(ts_parsers)
```

`nvim-treesitter` 的 `install()` 函数签名的稳定性未经官方承诺。确认所用版本支持此 API。

---

### 4.5 LSP server 配置中没有定义 `cmd`，依赖 nvim-lspconfig 默认值

**位置**：`lua/devil/servers.lua` + `lua/devil/lsp.lua`

```lua
local function resolve_server_bin(server, config)
  if type(config.cmd) == "table" and type(config.cmd[1]) == "string" and config.cmd[1] ~= "" then
    return config.cmd[1]
  end
  return server_binaries[server] or server
end
```

`resolve_server_bin` 先检查 `config.cmd`，但 `servers.lua` 中所有配置都**没有定义 `cmd` 字段**（它们依赖 nvim-lspconfig 自动解析）。

这意味着 `resolve_server_bin` 实际走的是 `server_binaries` fallback，检查的是 `server_binaries` 表中硬编码的可执行文件名。

**潜在问题**：如果 nvim-lspconfig 未来改变了默认 cmd 解析方式，这里的检查结果可能不可靠。不过当前因为直接用 `gopls` 等二进制名做检查且 nvim-lspconfig 默认也查这些名字，所以功能正常。

---

## 五、🔒 安全性 / 健壮性

### 5.1 `pcall` 使用得当

多处使用 `pcall(require, "xxx")` 处理可选依赖，符合最佳实践：
- `notify.lua`：nvim-notify 不存在时静默跳过
- `conform.lua`：conform 不存在时静默跳过
- `picker.lua`：fzf-lua 不存在时给出提示
- `init.lua`：`local.lua` 不存在时静默跳过 ✅

### 5.2 全局变量

```lua
-- keymap.lua
local space_visible = false  -- 模块级闭包变量，合理
```

`space_visible` 是模块局部变量，非全局污染 ✅。

### 5.3 `vim.notify` 全局替换

```lua
-- notify.lua
vim.notify = notify  -- 将原生 notify 替换为 nvim-notify
```

这是 nvim-notify 官方推荐做法，但当 notify 加载失败时 `vim.notify` 保持原生实现（因为 pcall 失败时 return） ✅。

---

## 六、💡 改进建议

### 6.1 添加 session 管理

当前配置没有设置 `sessionoptions`。建议添加：

```lua
vim.opt.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,globals"
```

### 6.2 `shortmess` 配置被注释

```lua
-- vim.opt.shortmess = "ilmnrx" -- flags to shorten vim messages, see :help 'shortmess'
```

被注释掉但下方有 `vim.opt.shortmess:append("c")`。如果原意是要设置 `ilmnrx`，应取消注释并改用 `vim.opt.shortmess = "ilmnrxc"`。

### 6.3 README 与实际不一致

README 列出的功能中提到 `LazyDev` 和 `conform`，但没有提到 `gitsigns`、`mini.icons`、`nvim-notify`。建议同步更新。

### 6.4 文件类型支持受限

`conform.lua` 只配置了 4 种语言的 formatter。`autocmds.lua` 的 Treesitter FileType 也只匹配 5 种语言。如果需要更广泛的语言支持，需要同步扩展这些配置。

### 6.5 `NetGet` 命令缺少错误处理

```lua
local is_json = pcall(vim.json.decode, body)
```

如果 `body` 非常大，`vim.json.decode` 可能耗时较长。建议对过大的 response 跳过 JSON 检测。

### 6.6 考虑添加 `vim.lsp.completion` 的 `keyword_range` 配置

当前 completion 没有设置 `keyword_range`，可能导致某些语言（如 Zig）的补全范围不准确。

---

## 七、✅ 做得好的地方

| 方面 | 评价 |
|------|------|
| **模块化** | 职责清晰，一个文件一个关注点 |
| **声明式键位** | 表驱动定义，统一注册，易维护 |
| **Fallback 链** | format（conform → LSP）、picker（fzf-lua → LSP native）都有降级策略 |
| **渐变式加载** | pcall 守卫所有可选依赖，不会因缺插件而崩溃 |
| **local.lua 机制** | 通过 pcall 加载机器级覆盖，不污染共享配置 |
| **诊断智能隐藏** | 光标在诊断行上时隐藏 virtual_text 的设计细心 |
| **补全高亮** | CmpItemKind 完整映射到 Treesitter 高亮组 |
| **健康检查** | DevilHealth 命令检查 Neovim 版本、LSP 二进制、命令、Treesitter |
| **自动格式化** | BufWritePre 自动调用 conform / LSP format |
| **built-in 工具** | 使用 vim.pack（非 lazy.nvim），使用 vim.lsp.completion（非 nvim-cmp）— 真正极简 |
| **自定义状态栏** | 信息全面（模式、文件、Git、诊断、LSP、进度）且视觉一致 |

---

## 八、优先级总结

| 优先级 | 问题 | 类型 |
|--------|------|------|
| 🔴 高 | `<leader>fm` 键位重复定义 | Bug |
| 🔴 高 | `get_diagnostics` 5 次重复调用 `vim.diagnostic.get` | 性能 Bug |
| 🟡 中 | `User GitSignsUpdate` autocmd 重复 | 冗余 |
| 🟡 中 | `vim._core.ui2` 私有 API | 兼容性风险 |
| 🟡 中 | `mousemoveevent = true` 性能 | 性能 |
| 🟡 中 | lock 文件中存在未使用的插件（onedarkpro, fidget） | 维护 |
| 🟢 低 | README 与代码不一致 | 文档 |
| 🟢 低 | `shortmess` 注释不明确 | 代码质量 |
| 🟢 低 | statusline render() 性能可优化 | 性能优化 |
