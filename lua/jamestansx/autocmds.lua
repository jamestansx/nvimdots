local utils = require("jamestansx.utils")
local autocmd = utils.create_autocmd

autocmd({ "TextYankPost" }, {
    desc = "Highlight text on yank",
    group = "HiTextOnYank",
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 40,
        })
    end,
})

autocmd({ "BufWritePre" }, {
    desc = "Create missing directories before saving files",
    group = "MkdirOnSave",
    pattern = "*",
    callback = function(ev)
        -- Ignore any URL pattern
        if not ev.match:match("^%w+://") then
            local file = vim.loop.fs_realpath(ev.match) or ev.match
            vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
        end
    end,
})

autocmd({ "BufWritePre" }, {
    desc = "Trim trailing whitespace before saving file",
    group = "TrimTrailingWhitespace",
    pattern = "*",
    callback = function()
        if vim.tbl_isempty(vim.b.editorconfig) then
            local view = vim.fn.winsaveview()
            vim.api.nvim_command("silent! undojoin")
            vim.api.nvim_command("silent keepjumps keeppatterns %s/\\s\\+$//e")
            vim.fn.winrestview(view)
        end
    end,
})

autocmd({ "BufReadPost" }, {
    desc = "Restore last cursor when opening a buffer",
    group = "RestoreLastCursor",
    pattern = "*",
    callback = function(ev)
        local ft = vim.bo[ev.buf].ft
        local ignore_ft = { "gitcommit", "gitrebase" }

        if not vim.tbl_contains(ignore_ft, ft) then
            local mark = vim.api.nvim_buf_get_mark(0, '"')
            if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
                pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
        end
    end,
})

autocmd({ "CmdLineEnter" }, {
    desc = "Disable relative number in cmdline mode",
    group = "ToggleRelativeNumber",
    pattern = "*",
    callback = function()
        local rnu = vim.wo.relativenumber
        if rnu then
            vim.api.nvim_win_set_var(0, "_toggleRelativeNumber", rnu)
            vim.wo.relativenumber = false
            vim.cmd.redraw()
        end
    end,
})

autocmd({ "CmdLineLeave" }, {
    desc = "Toggle back relative number on leaving cmdline",
    group = "ToggleRelativeNumber",
    pattern = "*",
    callback = function()
        local ok, rnu = pcall(vim.api.nvim_win_get_var, 0, "_toggleRelativeNumber")
        if ok and rnu then
            vim.wo.relativenumber = true
            vim.api.nvim_win_del_var(0, "_toggleRelativeNumber")
        end
    end,
})

autocmd({ "BufRead", "FileType" }, {
    desc = "Reset undo persistence on certain buffers",
    group = "NoUndoPersist",
    pattern = {
        -- Paths
        "/tmp/*",
        "*.tmp",
        "*.bak",

        -- Filetype
        "gitcommit",
        "gitrebase",
    },
    command = [[setlocal noundofile]],
})

autocmd({ "BufRead", "FileType" }, {
    desc = "Prevent accidental write to buffers that shouldn't be edited",
    group = "NotModifiable",
    pattern = {
        -- Paths
        "*.orig",
        "*.pacnew",
    },
    command = [[setlocal nomodifiable]],
})

autocmd({ "FileType" }, {
    desc = "Press `q` to close the window",
    group = "KeymapQuit",
    pattern = {
        "checkhealth",
        "help",
        "man",
        "nofile",
        "qf", -- TODO: Use bqf.nvim
        "vim",
    },
    callback = function(ev)
        vim.bo[ev.buf].buflisted = false
        vim.api.nvim_buf_set_keymap(ev.buf, "n", "q", "<CMD>close<CR>", { silent = true, noremap = true })
    end,
})
