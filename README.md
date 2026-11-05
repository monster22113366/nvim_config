# Neovim 配置：Windows / Linux 跨平台使用说明

## 目标与原则

本配置面向 C/C++、嵌入式开发与日常代码阅读，采用原生 Neovim 操作习惯、模块化 Lua 和 lazy.nvim 插件管理。通用配置不硬编码本机工具路径；平台专属设置统一放在 `lua/core/platform.lua`。

> 本文档根据当前已讨论的配置编写。迁移前应核对本机实际文件；本说明不会自动修改 Windows 电脑上的配置。

## 目录结构

```text
nvim/
├── init.lua
├── README.md
├── lazy-lock.json              # 若已生成，建议提交
└── lua/
    ├── core/
    │   ├── platform.lua       # 本机工具路径与平台判断
    │   ├── options.lua
    │   ├── keymaps.lua
    │   ├── lazy.lua
    │   └── lsp.lua
    └── plugins/
        ├── autopairs.lua
        ├── surround.lua
        ├── treesitter.lua
        ├── blink.lua
        ├── telescope.lua
        ├── neo-tree.lua
        └── conform.lua
```

## 配置路径

- Windows 原生 Neovim：`%LOCALAPPDATA%\nvim`，当前 Git Bash 示例为 `~/AppData/Local/nvim`。
- Linux：`~/.config/nvim`。
- 在 Neovim 中使用 `:echo stdpath('config')` 检查真实路径。

## Windows 本机路径：迁移或重装时检查

在 `lua/core/platform.lua` 的 `M.windows` 中集中修改：

| 字段 | 当前 Windows 路径 | 用途 |
| --- | --- | --- |
| `tree_sitter_cli_dir` | `C:/Users/34903/AppData/Roaming/npm/node_modules/tree-sitter-cli` | 包含原生 `tree-sitter.exe` 的目录 |
| `gcc` | `D:/APP/mingw64/bin/gcc.exe` | Tree-sitter 编译器及 Clangd 查询驱动 |
| `gpp` | `D:/APP/mingw64/bin/g++.exe` | Clangd C++ 查询驱动 |

**重要：** 这里必须指向真实可执行文件。`tree-sitter` 的 npm shell 包装脚本可能无法由 Windows 原生 Neovim 直接执行，因此使用包含 `tree-sitter.exe` 的目录。不要把 Windows 路径复制到 Linux 分支。

如果 `clangd`、`clang-format`、`rg` 不在 PATH 中，需要将对应安装目录加入操作系统 PATH，或另行配置工具命令；它们不由上述三项路径自动解决。

## 需要预先安装的软件

| 工具 | 用途 | 备注 |
| --- | --- | --- |
| Neovim | 编辑器 | 使用与插件兼容的较新版本；当前 Windows 为 0.12.6 |
| Git | lazy.nvim 安装和更新插件 | 必需 |
| GCC 或 Clang | C/C++ 编译、Tree-sitter 解析器编译 | Linux 通常通过系统包管理器安装 |
| clangd | C/C++ LSP | 需要能在 PATH 中执行 `clangd` |
| clang-format | C/C++ 格式化 | 需要能在 PATH 中执行 `clang-format` |
| ripgrep (`rg`) | Telescope `live_grep` | 需要能在 PATH 中执行 `rg` |
| tree-sitter CLI | 安装/构建 Tree-sitter 解析器 | 可通过 npm 或其他可靠方式安装 |
| Node.js/npm | tree-sitter CLI 的一种安装方式 | 如果用其他方式安装 CLI，可不需要 npm |
| Nerd Font | 图标字体 | 可选，但推荐在终端中配置 |
| CMake/Ninja | 部分 C/C++ 工程构建 | 按具体工程需要 |

Linux（Ubuntu/Debian）可先执行：

```bash
sudo apt update
sudo apt install -y git build-essential clangd clang-format ripgrep curl
```

Neovim 及 tree-sitter CLI 请按发行版和所需版本安装，不能假定发行版默认仓库版本一定满足当前插件要求。Node.js/npm、Nerd Font、CMake/Ninja 按需要另外安装。

## 平台配置代码

`lua/core/platform.lua`：

```lua
local M = {}
M.is_windows = vim.fn.has("win32") == 1

M.windows = {
    tree_sitter_cli_dir = "C:/Users/34903/AppData/Roaming/npm/node_modules/tree-sitter-cli",
    gcc = "D:/APP/mingw64/bin/gcc.exe",
    gpp = "D:/APP/mingw64/bin/g++.exe",
}

function M.setup()
    if not M.is_windows then
        return
    end
    local w = M.windows
    vim.env.PATH = w.tree_sitter_cli_dir .. ";" .. vim.env.PATH
    vim.env.CC = w.gcc
end

function M.clangd_cmd()
    local cmd = { "clangd", "--background-index", "--clang-tidy" }
    if M.is_windows then
        local w = M.windows
        table.insert(cmd, "--query-driver=" .. w.gcc .. "," .. w.gpp)
    end
    return cmd
end

return M
```

`init.lua` 中，平台配置要在插件和 LSP 加载前执行：

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "
require("core.platform").setup()
require("core.options")
require("core.keymaps")
require("core.lazy")
require("core.lsp")
```

`lua/core/lsp.lua`：

```lua
local platform = require("core.platform")
vim.lsp.config("clangd", {
    cmd = platform.clangd_cmd(),
    filetypes = { "c", "cpp" },
    root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" },
})
vim.lsp.enable("clangd")
```

**迁移时必须检查：** 从 `core/options.lua` 删除旧的 `vim.env.PATH`、`vim.env.CC` Windows 专属设置；从 `core/lsp.lua` 删除旧的硬编码 `--query-driver`，避免重复覆盖。

## Linux 迁移步骤

1. 安装上表中的必需外部工具，并检查版本。
2. 将本仓库复制或克隆到 `~/.config/nvim`。
3. 确保 `platform.lua` 存在；Linux 分支不会读取 `M.windows` 路径。
4. 运行 `nvim`，执行 `:Lazy sync` 安装插件。
5. 按当前 Tree-sitter 配置安装/更新解析器，必要时执行 `:TSUpdate`；解析器二进制不能直接跨 Windows/Linux 复制。
6. 打开 C/C++ 文件，检查 `:checkhealth`、`:LspInfo`（若当前版本支持）、`vim.lsp` 附加情况、`gd`、`K`、补全。
7. 验证 `<Space>ff`、`<Space>fg`、`<Space>e`、`<Space>cf`。

## 常用快捷键

| 按键 | 作用 |
| --- | --- |
| `<Space>ff` | Telescope 搜索文件 |
| `<Space>fg` | Telescope 全文搜索（需要 `rg`） |
| `<Space>fb` | 搜索已打开 Buffer |
| `<Space>fr` | 最近文件 |
| `<Space>e` | neo-tree 显示/隐藏 |
| `<Space>cf` | 手动格式化当前文件 |
| `Ctrl+w h/j/k/l` | Neovim 窗口焦点切换 |
| `gd` | Clangd 跳转定义 |
| `K` | Clangd 悬停信息 |

## 项目级配置注意事项

- `compile_commands.json` 中的 Windows 绝对路径（如 `D:/APP/...`）不能原样用于 Linux；建议在目标系统重新生成编译数据库。
- `.clangd`、`.clang-tidy`、`.clang-format` 一般可随项目迁移，但如包含绝对路径、平台专属编译选项或工具链配置，需要逐项检查。
- 嵌入式交叉编译（例如 ARM GCC）需要安装目标平台对应的工具链，并按项目配置 Clangd 的 `--query-driver` 或编译数据库；Linux 默认配置不自动推断交叉编译器。
- Windows Terminal 快捷键不属于 Neovim 配置；Linux 终端需要单独设置。
- 若 Linux 使用 Wayland/X11，系统剪贴板集成可能需要 `wl-clipboard` 或 `xclip` 等工具，按实际桌面环境安装。
- `lazy-lock.json` 可以提交 Git 以锁定插件版本；不应提交 `~/.local/share/nvim`、缓存、编译后的 Tree-sitter 解析器或 Windows 可执行文件。

## Git 管理建议

在配置根目录执行：

```bash
git init
git add init.lua lua README.md lazy-lock.json
git commit -m "Track portable Neovim configuration"
```

如果尚无 `lazy-lock.json`，先从 `git add` 命令中移除它。发布仓库前检查是否包含用户名、私人路径或其他不希望公开的本机信息；可以把 `M.windows` 的路径改成自己的占位示例，或将本机路径拆到不提交的本地覆盖文件。

## 验收命令

在目标终端执行：

```bash
nvim --version
clangd --version
clang-format --version
rg --version
gcc --version
tree-sitter --version
```

在 Neovim 内执行：

```vim
:echo stdpath('config')
:checkhealth
:Lazy
```

确认 Tree-sitter 高亮、Clangd 头文件解析、Telescope 搜索、neo-tree 和 conform 格式化正常后，迁移完成。
