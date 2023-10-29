return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufRead",
    opts = {
        scope = {
            enabled = false,
        },
        indent = {
            char = "│",
            tab_char = "│",
        },
    },
}
