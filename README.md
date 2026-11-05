# Neovim Config

基于 Lua + lazy.nvim 的轻量级 Neovim 配置，主要用于 C/C++ 开发，兼容 Windows / Linux。

## 功能

- **LSP**：clangd，补全、诊断、跳转
- **补全**：blink.cmp
- **语法高亮**：Treesitter
- **文件搜索**：Telescope
- **文件管理**：Neo-tree
- **格式化**：Conform
- **界面**：OneDark + Lualine

## 依赖

- Neovim ≥ 0.11
- Git
- clangd、GCC / G++
- Tree-sitter CLI
- Windows：win32yank

## 安装

**Windows（Git Bash）**

```bash
git clone https://github.com/monster22113366/nvim_config.git \
  ~/AppData/Local/nvim
```

**Linux**

```bash
git clone https://github.com/monster22113366/nvim_config.git \
  ~/.config/nvim
```

启动 `nvim`，配置会自动通过 Git 安装 [lazy.nvim](https://github.com/folke/lazy.nvim)，再由 lazy.nvim 安装其余插件。

无需手动安装插件，也无需将插件本体提交到 Git 仓库。

## 配置结构

```text
init.lua
lua/
├── core/
│   ├── options.lua
│   ├── keymaps.lua
│   ├── platform.lua
│   └── lsp.lua
└── plugins/
    └── *.lua
```

- `core/`：基础设置、快捷键、平台适配、LSP
- `plugins/`：插件独立配置
- `init.lua`：入口

## 常用命令

```vim
:Lazy
:checkhealth
:LspInfo
```

快捷键统一在 `lua/core/keymaps.lua` 中维护。
