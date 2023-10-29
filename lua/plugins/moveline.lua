return {
    "willothy/moveline.nvim",
    build = "make",
    keys = {
        {
            "<M-k>",
            function()
                require("moveline").up()
            end,
            mode = "n",
        },
        {
            "<M-j>",
            function()
                require("moveline").down()
            end,
            mode = "n",
        },
        {
            "<M-k>",
            function()
                require("moveline").block_up()
            end,
            mode = "v",
        },
        {
            "<M-j>",
            function()
                require("moveline").block_down()
            end,
            mode = "v",
        },
    },
}
