local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

local Align, Space, Null, Break
do
    Align = { provider = "%=" }

    Space = setmetatable({ provider = " " }, {
        __call = function(_, n)
            return { provider = string.rep(" ", n) }
        end,
    })

    Null = { provider = "" }

    Break = { provider = "%<" }
end

local FileNameBlock, HelpFileNameBlock
do
    local FileName = {
        init = function(self)
            self.lfilename = vim.fn.fnamemodify(self.filename, ":.")
            if self.lfilename == "" then
                self.lfilename = self.unnamed
            end
        end,
        flexible = 1,

        hl = { fg = utils.get_highlight("Directory").fg },

        { -- Full length relative path
            provider = function(self)
                return self.lfilename
            end,
        },
        { -- Shortened path
            provider = function(self)
                return vim.fn.pathshorten(self.lfilename, 2)
            end,
        },
        { -- File name only
            provider = function(self)
                return vim.fn.fnamemodify(self.filename, ":t")
            end,
        },
    }

    local FileFlags = {
        update = {
            "BufWritePost",
            "BufEnter",
            "InsertEnter",
            "TextChanged",
        },
        { -- Modified flag
            condition = function()
                return vim.bo.modified
            end,
            provider = function(self)
                return self.modified
            end,
            hl = { fg = "green" },
        },
        { -- Readonly flag (unmodifiable or readonly)
            condition = function()
                return not vim.bo.modifiable or vim.bo.readonly
            end,
            provider = function(self)
                return self.readonly
            end,
            hl = { fg = "peach" },
        },
    }

    local FileNameModifier = {
        hl = function()
            if vim.bo.modified then
                return { fg = "sky", bold = true, force = true }
            end
        end,
    }

    FileNameBlock = {
        static = {
            unnamed = "[No Name]",
            modified = "[+]",
            readonly = "[-]",
        },
        init = function(self)
            self.filename = vim.api.nvim_buf_get_name(0)
        end,

        utils.insert(FileNameModifier, FileName),
        FileFlags,
        Break,
    }

    HelpFileNameBlock = {
        update = { "BufEnter" },
        condition = function()
            return vim.bo.filetype == "help"
        end,
        provider = function()
            return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
        end,
        hl = { fg = "teal" },
    }
end

local GitBlock
do
    local GitBranch = {
        flexible = 3,

        {
            -- TODO: trigger event on NeogitStatusRefreshed
            update = { "BufEnter" },

            provider = function(self)
                return string.format("%s %s", "", self.git_branch)
            end,
        },
        Null,
    }

    GitBlock = {
        condition = conditions.is_git_repo,

        init = function(self)
            self.git_branch = vim.b.gitsigns_head
        end,

        hl = { fg = "mauve" },

        { Space, GitBranch, Space },
    }
end

local DiagnosticsBlock
do
    DiagnosticsBlock = {
        condition = conditions.has_diagnostics,
        static = {
            icons = {
                vim.fn.sign_getdefined("DiagnosticSignError")[1].text,
                vim.fn.sign_getdefined("DiagnosticSignWarn")[1].text,
                vim.fn.sign_getdefined("DiagnosticSignInfo")[1].text,
                vim.fn.sign_getdefined("DiagnosticSignHint")[1].text,
            },
            highlights = {
                "DiagnosticSignError",
                "DiagnosticSignWarn",
                "DiagnosticSignInfo",
                "DiagnosticSignHint",
            },
        },
        init = function(self)
            local buf_diagnostics = vim.diagnostic.get(0, { severity = { min = vim.diagnostic.severity.HINT } })
            local diagnostic_counts = { 0, 0, 0, 0 }

            for _, d in ipairs(buf_diagnostics) do
                diagnostic_counts[d.severity] = diagnostic_counts[d.severity] + 1
            end

            local children = {}
            for d, count in pairs(diagnostic_counts) do
                if count > 0 then
                    table.insert(children, {
                        provider = string.format("%s%s", self.icons[d], count),
                        hl = self.highlights[d],
                    })
                end
            end

            for i = 1, #children - 1, 1 do
                table.insert(children[i], { Space })
            end
            self.child = self:new(children, 1)
        end,

        {
            flexible = 4,
            {
                Space,
                {
                    update = { "DiagnosticChanged", "BufEnter" },
                    provider = function(self)
                        return self.child:eval()
                    end,
                },
                Space,
            },
            Null,
        },
    }
end

local LspBlock
do
    local LspActive = {
        flexible = 2,
        {
            update = { "LspAttach", "LspDetach" },
            provider = function(self)
                local names = {}
                for _, server in pairs(self.servers) do
                    table.insert(names, server.name)
                end

                return string.format("LSP: %s", table.concat(names, ","))
            end,
        },
        Null,
    }

    LspBlock = {
        condition = conditions.lsp_attached,
        init = function(self)
            self.servers = vim.lsp.get_active_clients({ bufnr = 0 })
        end,

        hl = { fg = "subtext0" },

        { Space, LspActive, Space },
    }
end

local FileType, FileEncoding
do
    FileType = {
        condition = function()
            return vim.bo.filetype ~= ""
        end,

        hl = { fg = "yellow", bold = true },
        update = { "FileType" },

        {
            provider = function()
                return vim.bo.filetype
            end,
        },
    }

    FileEncoding = {
        hl = { fg = "yellow" },
        provider = function()
            local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc
            return enc
        end,
    }
end

local PosBlock
do
    PosBlock = {
        update = { "CursorMoved", "ModeChanged" },
        hl = { fg = "subtext1" },

        { provider = "%3l:%-2v - %P" },
    }
end

local DefaultStatusLine, HelpStatusLine
do
    DefaultStatusLine = {
        { FileNameBlock, Space },
        { GitBlock, DiagnosticsBlock, LspBlock },
        Align,
        { FileType, Space, FileEncoding, Space },
        PosBlock,
    }

    HelpStatusLine = {
        condition = function()
            return conditions.buffer_matches({
                filetype = { "help" },
            })
        end,

        FileType,
        Space,
        HelpFileNameBlock,
        Align,
    }
end

-- TODO: dap
return {
    hl = { bg = "crust", fg = utils.get_highlight("StatusLine").fg },

    fallthrough = false,
    HelpStatusLine,
    DefaultStatusLine,
}
