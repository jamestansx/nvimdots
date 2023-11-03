local function on_attach(bufnr)
    local gs = package.loaded.gitsigns

    local map = function(mode, lhs, rhs, opts)
        opts = vim.tbl_extend("force", {
            noremap = true,
            silent = true,
            buffer = bufnr,
        }, opts or {})
        vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- stylua: ignore start

    -- Diff navigation
    map("n", "]c", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gs.next_hunk() end)
        return "<Ignore>"
    end, { expr = true })

    map("n", "[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gs.prev_hunk() end)
        return "<Ignore>"
    end, { expr = true })

    -- Actions
    map("n", "<leader>b", gs.blame_line)
    map("n", "<leader>B", function() gs.blame_line({ full = true }) end)

    -- stylua: ignore end
end

return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        signs = {
            add = { text = "│" },
            change = { text = "│" },
        },
        signcolumn = false,
        current_line_blame_opts = {
            delay = 500,
        },
        preview_config = {
            border = "none",
        },
        on_attach = on_attach,
    },
}
