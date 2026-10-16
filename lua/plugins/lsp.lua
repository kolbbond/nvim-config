-- LSP plugins: mason, lspconfig, blink, copilot, luasnip

return {
    -- server defaults (lsp/*.lua) for vim.lsp.config; mason installs binaries
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },

    -- Autocompletion (blink.cmp)
    {
        "saghen/blink.cmp",
        version = "1.*",
        dependencies = {
            "L3MON4D3/LuaSnip",
            "giuxtaposition/blink-cmp-copilot",
        },
    },

    -- LSP kind icons
    { "onsails/lspkind.nvim" },

    -- Clangd extensions for C++
    { "p00f/clangd_extensions.nvim" },

    -- Copilot
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({
                -- ghost text off: copilot surfaces in the blink menu instead
                suggestion = { enabled = false },
                panel = { enabled = false },
                server_opts_overrides = {
                    trace = "verbose",
                    settings = {
                        advanced = {
                            listCount = 10,
                            inlineSuggestCount = 3,
                        }
                    },
                }
            })
        end,
    },

    -- Minuet AI
    { "milanglacier/minuet-ai.nvim" },

    -- Prettier
    { "MunifTanjim/prettier.nvim" },

    -- Workspace diagnostics
    { "artemave/workspace-diagnostics.nvim" },

    -- Fidget - LSP progress indicator
    {
        "j-hui/fidget.nvim",
        opts = {},
    },
}
