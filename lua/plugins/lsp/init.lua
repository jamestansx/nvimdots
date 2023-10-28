require("jamestansx.utils").create_autocmd({ "LspAttach" }, {
    desc = "Setup lsp on_attach",
    group = "LspOnAttach",
    callback = function(ev)
        local bufnr = ev.buf
        ---@diagnostic disable-next-line: unused-local
        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
        require("plugins.lsp.keymaps").on_attach(bufnr)
    end,
})

return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("plugins.lsp.handlers") -- Override lsp handlers
            require("plugins.lsp.servers")
        end,
    },
    {
        "j-hui/fidget.nvim",
        tag = "legacy",
        event = "LspAttach",
        opts = {
            text = { spinner = "dots" },
            window = {
                blend = 0,
                relative = "editor",
            },
            timer = {
                fidget_decay = 300,
                task_decay = 300,
            },
        },
    },
    {
        "akinsho/flutter-tools.nvim",
        event = "BufRead pubspec.yaml",
        ft = { "dart" },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            fvm = true,
        },
    },
}
