return {
    "rebelot/heirline.nvim",
    event = "UIEnter",
    opts = function()
        return {
            statusline = require("plugins.heirline.statusline"),
            opts = {
                colors = require("catppuccin.palettes").get_palette(vim.g.catppuccin_flavour),
            },
        }
    end,
}
