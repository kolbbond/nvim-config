local ok, blink = pcall(require, "blink.cmp")
if not ok then return end

blink.setup({
    snippets = { preset = 'luasnip' },

    keymap = {
        preset = 'none',
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-y>'] = { 'accept', 'fallback' },
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
        ['<C-space>'] = { 'show', 'fallback' },
        ['<C-e>'] = { 'cancel', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
    },

    sources = {
        default = { 'copilot', 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
            copilot = {
                name = "copilot",
                module = "blink-cmp-copilot",
                score_offset = 100,
                async = true,
            },
        },
    },

    cmdline = {
        enabled = true,
        keymap = { preset = 'cmdline' },
        sources = { 'cmdline', 'path' },
        completion = {
            menu = { auto_show = true },
            ghost_text = { enabled = true },
        },
    },

    completion = {
        menu = {
            draw = {
                columns = {
                    { 'kind_icon' },
                    { 'label', 'label_description', gap = 1 },
                    { 'kind' },
                },
            },
        },
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
        },
    },

    appearance = {
        nerd_font_variant = 'mono',
        kind_icons = {
            Copilot = "",
        },
    },
})

vim.api.nvim_set_hl(0, "BlinkCmpKindCopilot", { fg = "#6CC644" })
