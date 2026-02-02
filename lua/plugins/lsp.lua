-- LSP plugins: lsp-zero, mason, cmp, copilot, luasnip

return {
    -- LSP Zero - Main LSP configuration
    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v3.x",
        dependencies = {
            -- Mason for managing LSP servers
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },

            -- LSP Support
            { "neovim/nvim-lspconfig" },

            -- Autocompletion
            { "hrsh7th/nvim-cmp" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "L3MON4D3/LuaSnip" },
        },
    },

    -- Command line completion
    { "hrsh7th/cmp-cmdline" },

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

    -- Copilot CMP integration
    {
        "zbirenbaum/copilot-cmp",
        event = "InsertEnter",
        dependencies = { "zbirenbaum/copilot.lua" },
        config = function()
            require("copilot_cmp").setup()
        end
    },

    -- Minuet AI
    { "milanglacier/minuet-ai.nvim" },

    -- Null-ls for formatters/linters
    { "jose-elias-alvarez/null-ls.nvim" },

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
