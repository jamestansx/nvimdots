return {
    {
        "hrsh7th/nvim-cmp",
        version = false, -- Last release is way too old
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",
            "L3MON4D3/LuaSnip",
        },
        event = "InsertEnter",
        cmd = { "CmpInfo" },
        opts = {
            max_index_file_size = 1024 * 1024, -- 1MB
        },
        config = function(_, opts)
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            -- TODO: Setup cmdline
            cmp.setup({
                completion = {
                    completeopt = table.concat(vim.opt.completeopt:get(), ","),
                },
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = {
                        scrollbar = false,
                    },
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<C-y>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }),
                    ["<CR>"] = cmp.mapping.confirm({ select = false }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "path" },
                }, {
                    {
                        name = "buffer",
                        option = {
                            -- Only load buffers that are smaller than max_size, to increase performance
                            get_bufnrs = function()
                                local bufs = vim.api.nvim_list_bufs()

                                -- Return early if there's only 1 currently active buffer
                                if #bufs == 1 and vim.api.nvim_buf_is_loaded(bufs[1]) then
                                    return bufs
                                end

                                -- Return all buffers that its size is smaller than max_size
                                local bufnrs = {}
                                for _, bufnr in ipairs(bufs) do
                                    local lc = vim.api.nvim_buf_line_count(bufnr)
                                    local byte_size = vim.api.nvim_buf_get_offset(bufnr, lc)

                                    if byte_size <= opts.max_index_file_size and vim.api.nvim_buf_is_loaded(bufnr) then
                                        table.insert(bufnrs, bufnr)
                                    end
                                end
                                return bufnrs
                            end,
                        },
                    },
                }),
                sorting = {
                    priority_weight = 2,
                    comparators = {
                        cmp.config.compare.offset,
                        cmp.config.compare.exact,
                        cmp.config.compare.score,

                        -- ref: https://github.com/lukas-reineke/cmp-under-comparator
                        function(entry1, entry2)
                            local _, entry1_under = entry1.completion_item.label:find("^_+")
                            local _, entry2_under = entry2.completion_item.label:find("^_+")
                            entry1_under = entry1_under or 0
                            entry2_under = entry2_under or 0
                            if entry1_under > entry2_under then
                                return false
                            elseif entry1_under < entry2_under then
                                return true
                            end
                        end,

                        cmp.config.compare.recently_used,
                        cmp.config.compare.locality,
                        cmp.config.compare.kind,
                        cmp.config.compare.length,
                        cmp.config.compare.order,
                    },
                },
                experimental = {
                    ghost_text = {
                        hl_group = "LspCodeLens",
                    },
                },
            })
        end,
    },
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        lazy = true,
        dependencies = {
            "rafamadriz/friendly-snippets",
            config = function()
                require("luasnip.loaders.from_vscode").lazy_load()
            end,
        },
        opts = {
            region_check_events = { "CursorMoved", "CursorHold", "InsertEnter" },
            delete_check_events = { "InsertLeave" },
        },
    },
}
