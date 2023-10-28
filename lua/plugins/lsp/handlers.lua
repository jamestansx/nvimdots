local utils = require("jamestansx.utils")

-- XXX: Require neovim nightly to enable `anchor_bias` option
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(function(_, result, ctx, config)
    return vim.lsp.handlers.signature_help(_, utils.lsp_remove_docs(result) or {}, ctx, config)
end, { anchor_bias = "above" })

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    update_in_insert = true,
    severity_sort = true,
    virtual_text = { source = "if_many" },
})
