local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

local Align, Space, Null
do
    Align = { provider = "%=" }
    Space = setmetatable({ provider = " " }, {
        __call = function(_, n)
            return { provider = string.rep(" ", n) }
        end,
    })
    Null = { provider = "" }
end

local FileNameBlock
do
    local FileName = {
        init = function(self)
            if self.filename == "" then
                self.relpath = self.unnamed
            else
                self.relpath = vim.fn.fnamemodify(self.filename, ":~:.")
            end
        end,
        flexible = 1,

        -- Full relative path
        {
            provider = function(self)
                return self.relpath
            end,
        },

        -- Shorten relative path
        {
            provider = function(self)
                return vim.fn.pathshorten(self.relpath, 2)
            end,
        },

        -- File name only
        {
            provider = function(self)
                return vim.fn.fnamemodify(self.relpath, ":t")
            end,
        },
    }

    local FileFlags = {
        -- Modified flag
        {
            condition = function()
                return vim.bo.modified
            end,
            provider = function(self)
                return self.modified
            end,
        },

        -- Readonly flag (not modifiable or readonly)
        {
            condition = function()
                return not vim.bo.modifiable or vim.bo.readonly
            end,
            provider = function(self)
                return self.readonly
            end,
        },
    }

    FileNameBlock = {
        init = function(self)
            self.modified = "[+]"
            self.readonly = "[-]"
            self.unnamed = "[No Name]"

            self.filename = vim.api.nvim_buf_get_name(0)
        end,

        hl = { bg = "blue", fg = "mantle", bold = true },

        FileName,
        FileFlags,
        Space,
        { provider = "%<" },
    }
end

local FilePropBlock
do
    local FileType = {
        provider = function()
            return string.format(" %s ", vim.bo.filetype)
        end,
    }

    FilePropBlock = {
        condition = function()
            return vim.bo.filetype ~= ""
        end,

        hl = { fg = "blue" },
        FileType,
    }
end

local DiagnosticsBlock
do
    local diagnostic_signs = {
        error_icon = "E",
        warn_icon = "W",
        info_icon = "I",
        hint_icon = "H",
    }

    local errors = {
        provider = function(self)
            if self.errors > 0 then
                return table.concat({ self.error_icon, ":", self.errors, " " })
            end
        end,
        hl = "DiagnosticSignError",
    }
    local warnings = {
        provider = function(self)
            if self.warnings > 0 then
                return table.concat({ self.warn_icon, ":", self.warnings, " " })
            end
        end,
        hl = "DiagnosticSignWarn",
    }
    local hints = {
        provider = function(self)
            if self.hints > 0 then
                return table.concat({ self.hint_icon, ":", self.hints, " " })
            end
        end,
        hl = "DiagnosticSignHint",
    }
    local info = {
        provider = function(self)
            if self.info > 0 then
                return table.concat({ self.info_icon, ":", self.info, " " })
            end
        end,
        hl = "DiagnosticSignInfo",
    }

    DiagnosticsBlock = {
        condition = conditions.has_diagnostics,
        static = diagnostic_signs,
        init = function(self)
            self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
            self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
            self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
            self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
        end,
        update = { "DiagnosticChanged", "BufEnter" },
        hl = { bg = "surface1" },

        errors,
        warnings,
        info,
        hints,
    }
end

local CurPosBlock
do
    local Ruler = {
        provider = function()
            local line = vim.fn.line(".")
            local col = vim.fn.virtcol(".")
            return string.format(" %3d:%-2d", line, col)
        end,
        hl = { bg = "blue", fg = "mantle" },
    }

    local ScrollPercentage = {
        provider = function()
            local cur = vim.fn.line(".")
            local total = vim.fn.line("$")
            if cur == 1 then
                return " Top "
            elseif cur == total then
                return " Bot "
            else
                return string.format(" %2d%%%% ", math.floor(cur / total * 100))
            end
        end,
        hl = { bg = "surface1", fg = "blue" },
    }

    CurPosBlock = {

        ScrollPercentage,
        Ruler,
    }
end

local LspBlock
do
    local LspActive = {
        provider = function()
            local lspnames = {}

            for _, server in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
                table.insert(lspnames, server.name)
            end

            return string.format(" [%s] ", table.concat(lspnames, " "))
        end,
    }

    LspBlock = {
        condition = conditions.lsp_attached,
        update = { "LspAttach", "LspDetach" },
        hl = { fg = "blue" },

        LspActive,
    }
end

local GitBlock
do
    local GitBranch = {
        provider = function()
            return string.format(" %s %s ", "", vim.b.gitsigns_head)
        end,
    }

    GitBlock = {
        condition = conditions.is_git_repo,

        hl = { bg = "surface1", fg = "blue", bold = true },
        GitBranch,
    }
end

local VimHelpBlock
do
    local FileName = {
        provider = function()
            local filename = vim.api.nvim_buf_get_name(0)
            return vim.fn.fnamemodify(filename, ":t")
        end,
    }

    VimHelpBlock = {
        hl = { bg = "blue", fg = "mantle", bold = true },

        FileName,
    }
end

local DefaultStatusLine = {
    FileNameBlock,
    GitBlock,
    DiagnosticsBlock,
    LspBlock,
    Align,
    FilePropBlock,
    CurPosBlock,
}

local VimHelpStatusLine = {
    condition = function()
        return vim.bo.filetype == "help"
    end,

    VimHelpBlock,
    Space,
    FilePropBlock,
    Align,
}

-- TODO: Debugger
return {
    fallthrough = false,

    VimHelpStatusLine,
    DefaultStatusLine,
}
