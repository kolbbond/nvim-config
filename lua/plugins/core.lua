-- Core plugins: treesitter, plenary, devicons, notify

return {
    -- Plenary - Lua utility functions (required by many plugins)
    { "nvim-lua/plenary.nvim" },

    -- Treesitter - Syntax highlighting and parsing
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
    },

    -- Rainbow delimiters - Color different delimiters
    { "HiPhish/rainbow-delimiters.nvim" },

    -- Devicons - File icons
    { "nvim-tree/nvim-web-devicons" },

    -- Notify - Better notifications
    {
        "rcarriga/nvim-notify",
        config = function()
            vim.notify = require("notify")
        end
    },

    -- Lazydev - Lua development support
    { "folke/lazydev.nvim" },

    -- Neodev (for Lua LSP support)
    { "folke/neodev.nvim" },

    -- Dressing - Better UI for inputs
    { "stevearc/dressing.nvim" },

    -- Colorizer - Show colors in code
    { "norcalli/nvim-colorizer.lua" },

    -- Color picker
    { "ziontee113/color-picker.nvim" },
}
