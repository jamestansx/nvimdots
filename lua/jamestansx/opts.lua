local autocmd = require("jamestansx.utils").create_autocmd

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.shortmess:append({
    I = true, -- Intro screen
    C = true, -- Ins-completion "scanning tags"
    c = true, -- Ins-completion message
})

vim.opt.title = true
vim.opt.titlelen = 100
vim.opt.titlestring = "%f%( [%M%R%H%W]%)%( -%a%)%<"

vim.opt.laststatus = 3
vim.opt.colorcolumn = "80"
vim.opt.cursorline = true
vim.opt.cmdheight = 2

-- TODO: Make signcolumn static so that it doesn't jump around
vim.opt.signcolumn = "yes"

vim.opt.pumblend = 10
vim.opt.winblend = 10
vim.opt.pumheight = 5

vim.opt.confirm = true

vim.opt.redrawtime = 1000
vim.opt.updatetime = 300
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 10

vim.opt.virtualedit = { "block" } -- Visual block

vim.opt.completeopt = {
    "menuone", -- Popup even when there's only one match
    "noinsert", -- Don't insert until a selection is made
    "noselect", -- Don't select, force user to select from menu
    "preview", -- Show extra info about the current selection
}

vim.opt.wildmode = { "list:longest", "full" }
--vim.opt.wildchar = string.byte("")
vim.opt.wildignorecase = true
vim.opt.wildignore:append({ ".git", ".hg", ".svn" }) -- version control
vim.opt.wildignore:append({ "*.swp", "*.lock" }) -- lock file
vim.opt.wildignore:append({ "*.pyc", "*.pycache" }) -- python
vim.opt.wildignore:append({ "**/node_modules/**" }) -- JavaScript
vim.opt.wildignore:append({ "*.o", "*.out", "*.obj" }) -- executable
vim.opt.wildignore:append({ "*.bmp", "*.gif", "*.ico", "*.png", "*.jpeg", "*.webp" }) -- picture
vim.opt.wildignore:append({ "*.mkv", "*.mov", "*.mp4", "*.webm", "*.webp" }) -- video
vim.opt.wildignore:append({ "*.mp3", "*.wav" }) -- song
vim.opt.wildignore:append({ "*.zip", "*.tar.gz", "*.tar.bz2", "*.tar.xz" }) -- zip
vim.opt.wildignore:append({ "*.doc", "*.docx", "*.pdf", "*.pptx" }) -- document
vim.opt.wildignore:append({ "*.otf", "*.ttf", "*.woff" }) -- font

vim.opt.spelllang = { "en", "cjk" }
vim.opt.spelloptions = { "camel" }
vim.opt.spellsuggest = { "best,5" }

vim.opt.undofile = true

vim.opt.mouse = "a"
vim.opt.mousemodel = "extend"

-- TODO: Disable conceal in ceratin filetypes
vim.opt.conceallevel = 2
vim.opt.concealcursor = "nc" -- Similar to vim help page settings

-- Performance
vim.opt.synmaxcol = 500

-- Proper search
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.scrolloff = 2
vim.opt.sidescrolloff = 2

vim.opt.exrc = true
vim.opt.modelines = 1

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.shiftround = true

vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.breakindentopt = { "sbr" }
vim.opt.showbreak = "↪"
vim.opt.linebreak = true -- Only break at `breaat` chars
vim.opt.breakat = [[ ,]]

vim.opt.list = true
vim.opt.listchars = {
    trail = "·",
    tab = "  ⇥",
    nbsp = "◻",
    extends = "→",
    precedes = "←",
}
vim.opt.fillchars = {
    fold = " ",
    foldopen = "▽",
    foldsep = " ",
    foldclose = "▷",
}

vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "cursor"

vim.opt.diffopt:append({
    "iwhite",
    "algorithm:histogram",
    "indent-heuristic",
})

vim.diagnostic.config({
    virtual_text = { source = "if_many" },
    severity_sort = true,
    update_in_insert = true,
})

vim.opt.jumpoptions = { "stack", "view" }

if vim.fn.executable("rg") == 1 then
    vim.opt.grepprg = "rg --no-heading --smart-case --vimgrep"
    vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

autocmd({ "BufEnter" }, {
    desc = "Set default formatoptions",
    group = "DefaultFormatOptions",
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions = {
            t = true, -- Wrap text using `textwidth`
            c = true, -- Wrap comment using `textwidth`
            q = true, -- Enable formatting of comment with `gq`
            r = true, -- Continue comment on Enter in insert mode
            n = true, -- Detect list for formatting
            j = true, -- Remove comment leader when joining lines
            b = true, -- Auto wrap in insert mode, ignore old lines
        }
    end,
})
