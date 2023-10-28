local M = {}

function M.create_autocmd(ev, opts)
    if opts.group and vim.fn.exists("#" .. opts.group) == 0 then
        vim.api.nvim_create_augroup(opts.group, { clear = true })
    end
    vim.api.nvim_create_autocmd(ev, opts)
end

function M.lsp_remove_docs(docs)
    if docs then
        for i = 1, #docs.signatures do
            if docs.signatures[i] and docs.signatures[i].documentation then
                if docs.signatures[i].documentation.value then
                    docs.signatures[i].documentation.value = nil
                else
                    docs.signatures[i].documentation = nil
                end
            end
        end
    end
    return docs
end

function M.get_python_path()
    -- Env
    local env_var = vim.env.VIRTUAL_ENV
    if env_var then
        return M.path_join(env_var, "bin", "python")
    end

    -- Root pattern of `pyvenv.cfg`
    local homedir = vim.loop.os_homedir()
    local util = require("lspconfig").util
    local result = vim.fs.find("pyvenv.cfg", {
        -- TODO: Remove dependency on lspconfig
        path = util.root_pattern({
            "pyproject.toml",
            "setup.py",
            "setup.cfg",
            "requirements.txt",
            "Pipfile",
            ".git",
        })(util.path.sanitize(vim.api.nvim_buf_get_name(0), 0)),
        stop = homedir,
        upward = false,
    })[1]
    if result then
        return M.path_join(vim.fs.dirname(result), "bin", "python")
    end

    -- Fallback
    return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

function M.path_join(...)
    return table.concat(vim.tbl_flatten({ ... }), "/")
end

return M
