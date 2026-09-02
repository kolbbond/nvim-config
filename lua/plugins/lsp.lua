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

            -- Snippets
            { "L3MON4D3/LuaSnip" },
        },
    },

    -- Autocompletion (blink.cmp)
    {
        "saghen/blink.cmp",
        version = "1.*",
        dependencies = {
            "L3MON4D3/LuaSnip",
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
                -- ghost text is the in-buffer AI surface; blink handles symbols
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    keymap = {
                        accept = "<M-y>",
                        -- <M-hjkl> belong to vim-tmux-navigator
                        next = "<M-]>",
                        prev = "<M-[>",
                        dismiss = "<C-]>",
                    },
                },
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
