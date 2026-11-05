return {
    "navarasu/onedark.nvim",

    lazy = false,
    priority = 1000,

    config = function()
        require("onedark").setup({
            style = "darker",
            transparent = false,
            term_colors = true,
        })

        require("onedark").load()
    end,
}
