-- Theme plugins: gruvbox (fork) and alternatives

return {
    -- Gruvbox (custom fork - primary theme)
    {
        "kolbbond/gruvbox.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("gruvbox").setup({
                contrast = "hard",
                overrides = {
                    ["@keyword"] = { fg = "#882206", bold = true, italic = false },
                    ["@keyword.function"] = { fg = "#cc2206" },
                    ["@keyword.conditional"] = { fg = "#df5520" },
                    ["@variable"] = { fg = "#bbbbbb" },
                    ["@variable.member"] = { fg = "#ddcccc" },
                    ["@function.call"] = { fg = "#ddcccc" },
                    ["@property"] = { fg = "#aaddaa" },
                    ["@number"] = { fg = "#885588" },
                    ["@type"] = { fg = "#d18a20" },
                    ["@type.builtin"] = { fg = "#a18a20" },
                    ["@comment"] = { fg = "#777777" },
                    ["@comment.lua"] = { fg = "#ffffff" },
                    ["@string"] = { fg = "#646a20", italic = true },
                    ["@constant.builtin"] = { fg = "#bb55bb" },
                    ["@function.builtin"] = { fg = "#a18a20" },
                },
                palette_overrides = {
                    dark0_hard = "#1d1a1a",
                },
                dim_inactive = false,
                transparent_mode = false,
                terminal_colors = false,
                undercurl = false,
                underline = false,
                bold = false,
                italic = {
                    strings = false,
                    emphasis = false,
                    comments = false,
                    operators = false,
                    folds = false,
                },
                strikethrough = true,
                invert_selection = true,
                invert_signs = false,
                invert_tabline = true,
                inverse = true,
            })
            vim.cmd("colorscheme gruvbox")

            -- Custom highlights
            vim.api.nvim_set_hl(0, "LineNr", { fg = "#555555", bg = "#1d2021", italic = false })
            vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#8ddabb", bg = "#3c3836", italic = true, bold = true })
            vim.api.nvim_set_hl(0, "CursorLine", { bg = "#3c3836", italic = false, bold = true })
            vim.api.nvim_set_hl(0, "Comment", { fg = "#4C8687" })
        end,
    },

    -- Gruvbox alternatives
    { "luisiacc/gruvbox-baby" },
    { "sainnhe/gruvbox-material" },

    -- Rose Pine
    { "rose-pine/neovim", name = "rose-pine" },

    -- Colorbuddy
    { "tjdevries/colorbuddy.nvim" },

    -- GitHub theme
    { "projekt0n/github-nvim-theme" },

    -- Lush - Theme creation framework
    { "rktjmp/lush.nvim" },

    -- Tokyo Night
    { "folke/tokyonight.nvim" },

    -- Modus themes
    { "miikanissi/modus-themes.nvim" },

    -- Oxocarbon
    { "nyoom-engineering/oxocarbon.nvim" },

    -- Nord
    { "gbprod/nord.nvim" },

    -- VSCode
    { "Mofiqul/vscode.nvim" },

    -- Kanagawa
    { "rebelot/kanagawa.nvim" },

    -- Flow
    { "0xstepit/flow.nvim" },

    -- Rasmus
    { "kvrohit/rasmus.nvim" },

    -- Darkvoid
    { "aliqyan-21/darkvoid.nvim" },

    -- Falcon
    { "fenetikm/falcon" },

    -- Miasma
    { "xero/miasma.nvim" },

    -- Fluoromachine (neon)
    { "maxmx03/fluoromachine.nvim" },

    -- Moonlight (neon)
    { "shaunsingh/moonlight.nvim" },

    -- Lackluster
    { "slugbyte/lackluster.nvim" },
}
