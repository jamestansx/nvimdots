return {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    lazy = true,
    keys = {
        {
            "<leader>f",
            function()
                require("conform").format({
                    async = false,
                    lsp_fallback = true,
                })
            end,
            mode = { "n", "v" },
            desc = "Format buffer",
        },
    },
    init = function()
        vim.opt.formatexpr = [[v:lua.require("conform").formatexpr()]]
    end,
    opts = {
        formatters_by_ft = {
            lua = { "stylua" },
        },
        log_level = vim.log.levels.ERROR,
    },
}
