local M = {}

function M.on_attach(bufnr)
    local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
    -- Resolves keymap capabilities over all clients attached to the buffer
    local has = function(method)
        for _, client in ipairs(clients) do
            if client.supports_method(method) then
                return true
            end
        end
        return false
    end

    local map = function(mode, lhs, rhs, opts)
        if opts.has and has(opts.has) then
            opts.has = nil
            opts.silent = opts.silent ~= false
            opts.noremap = opts.noremap ~= false
            opts.buffer = bufnr
            vim.keymap.set(mode, lhs, rhs, opts)
        end
    end

    -- stylua: ignore start

    -- Goto xxx
    map("n", "gd", vim.lsp.buf.definition, { has = "textDocument/definition" })
    map("n", "gr", vim.lsp.buf.references, { has = "textDocument/references" })
    map("n", "gi", vim.lsp.buf.implementation, { has = "textDocument/implementation" })
    map("n", "gD", vim.lsp.buf.type_definition, { has = "textDocument/typeDefinition" })

    -- TODO: document symbol

    -- Help
    map("n", "K", vim.lsp.buf.hover, { has = "textDocument/hover" })
    map({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help, { has = "textDocument/signatureHelp" })

    -- Action
    map("n", "<leader>a", vim.lsp.buf.code_action, { has = "textDocument/codeAction" })
    -- Formatting will be handled by `conform.nvim`
    --map("n", "<leader>f", vim.lsp.buf.format, { has = "textDocument/formatting" })
    map("n", "<leader>r", vim.lsp.buf.rename, { has = "textDocument/rename" })

    -- stylua: ignore end
end

return M
