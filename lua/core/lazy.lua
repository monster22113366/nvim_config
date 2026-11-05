local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        { import = "plugins" },
    },

    checker = {
        enabled = false,
    },

    change_detection = {
        notify = false,
    },
})
