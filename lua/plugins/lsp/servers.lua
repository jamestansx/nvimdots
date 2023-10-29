local capabilites = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require("lspconfig")
local utils = require("jamestansx.utils")

lspconfig.lua_ls.setup({
    capabilities = capabilites,
    on_attach = function(client, _)
        client.server_capabilities.documentFormattingProvider = false
    end,
})

lspconfig.jedi_language_server.setup({
    capabilities = capabilites,
    init_options = {
        diagnostics = { enable = true },
        workspace = { environmentPath = utils.get_python_path() },
    },
})
