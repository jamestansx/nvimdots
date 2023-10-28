local map = function(mode, lhs, rhs, opts)
    opts = vim.tbl_extend("force", {
        noremap = true,
        silent = true,
    }, opts or {})
    vim.keymap.set(mode, lhs, rhs, opts)
end

-- Space as leader key
map("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Smart j/k
-- Avoid gj/gk in operation pending mode
map({ "n", "v" }, "j", "v:count || mode(1)[0:1] == 'no' ? 'j': 'gj'", { expr = true })
map({ "n", "v" }, "k", "v:count || mode(1)[0:1] == 'no' ? 'k': 'gk'", { expr = true })

-- Center search result
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "*", "*zzzv")
map("n", "#", "#zzzv")
map("n", "g*", "g*zzzv")

map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Source: https://github.com/mhinz/vim-galore#saner-command-line-history
map("c", "<C-n>", function()
    return vim.fn.wildmenumode() == 1 and "<C-n>" or "<Down>"
end, { expr = true, silent = false })
map("c", "<C-p>", function()
    return vim.fn.wildmenumode() == 1 and "<C-p>" or "<Up>"
end, { expr = true, silent = false })

-- Use the home row keys!!!!!
map("", "<Up>", "<Nop>")
map("", "<Down>", "<Nop>")
map("", "<Left>", "<Nop>")
map("", "<Right>", "<Nop>")

map("n", "<leader>e", vim.diagnostic.open_float)
map("n", "<leader>q", vim.diagnostic.setloclist)
map("n", "[d", vim.diagnostic.goto_prev)
map("n", "]d", vim.diagnostic.goto_next)
map("n", "[e", function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end)
map("n", "]e", function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end)
map("n", "[w", function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
end)
map("n", "]w", function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
end)

map("n", "gp", "`[v`]") -- Select last pasted text

-- System clipboard
map({ "n", "v" }, "<leader>y", [["+y]])
map({ "n", "v" }, "<leader>Y", [["+Y]])
map({ "n", "v" }, "<leader>p", [["+p]])
map({ "n", "v" }, "<leader>P", [["+P]])

-- Black hole _
map({ "n", "v" }, "<leader>d", [["_d]])
map({ "n", "v" }, "<leader>D", [["_D]])

-- XXX: Experimental section!!!
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { silent = false }) -- Replace cursor word
