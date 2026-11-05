local M = {}

M.is_windows = vim.fn.has("win32") == 1

M.windows = {
    tree_sitter_cli_dir =
        "C:/Users/34903/AppData/Roaming/npm/node_modules/tree-sitter-cli",

    gcc = "D:/APP/mingw64/bin/gcc.exe",
    gpp = "D:/APP/mingw64/bin/g++.exe",
}

function M.setup()
    if not M.is_windows then
        return
    end

    vim.env.PATH =
        M.windows.tree_sitter_cli_dir .. ";" .. vim.env.PATH

    vim.env.CC = M.windows.gcc

    vim.g.clipboard = {
    name = "win32yank",
    copy = {
        ["+"] = { "win32yank.exe", "-i", "--crlf" },
        ["*"] = { "win32yank.exe", "-i", "--crlf" },
    },
    paste = {
        ["+"] = { "win32yank.exe", "-o", "--lf" },
        ["*"] = { "win32yank.exe", "-o", "--lf" },
    },
    cache_enabled = 0,
}

end

function M.clangd_cmd()
    local cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
    }

    if M.is_windows then
        table.insert(
            cmd,
            "--query-driver="
                .. M.windows.gcc
                .. ","
                .. M.windows.gpp
        )
    end

    return cmd
end

return M
