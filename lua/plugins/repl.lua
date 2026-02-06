-- REPL plugins: vim-slime, iron.nvim, nvim-matlab, molten, jupynium

return {
    -- MATLAB (custom fork)
    { "kolbbond/nvim-matlab" },

    -- Iron - REPL for Python/Octave
    { "Vigemus/iron.nvim" },

    -- Slime - Send code to tmux panes
    { "jpalardy/vim-slime" },

    -- Molten - Jupyter-style code execution in Neovim
    -- NOTE: Cannot be lazy-loaded (remote plugin limitation)
    {
        "benlubas/molten-nvim",
        build = ":UpdateRemotePlugins",
        lazy = false,
        dependencies = {
            "3rd/image.nvim",
        },
    },

    -- Image rendering (for molten output)
    -- NOTE: Requires kitty graphics protocol (use WezTerm, not Windows Terminal)
    {
        "3rd/image.nvim",
        opts = {
            backend = "kitty",
            max_width = 100,
            max_height = 12,
            max_height_window_percentage = math.huge,
            max_width_window_percentage = math.huge,
            window_overlap_clear_enabled = true,
            window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
        },
    },

    -- Jupynium - Sync with Jupyter Notebook
    {
        "kiyoon/jupynium.nvim",
        build = "pip install --user jupynium",
        init = function()
            -- Snap Firefox can't access /tmp profiles from geckodriver.
            -- Point TMPDIR to home so Snap can reach it.
            local tmpdir = vim.fn.expand("~/.cache/geckodriver-tmp")
            vim.fn.mkdir(tmpdir, "p")
            vim.env.TMPDIR = tmpdir
        end,
        opts = {
            -- Snap Firefox can't share profiles with geckodriver.
            firefox_profiles_ini_path = nil,
            firefox_profile_name = nil,
            default_notebook_URL = "localhost:8888",
            notebook_dir = "~/notebooks",
            autoscroll = {
                enable = true,
                mode = "always",
                cell = { top_margin_percent = 20 },
            },
            -- We define our own keymaps in after/plugin/jupynium.lua
            use_default_keybindings = false,
            textobjects = { use_default_keybindings = false },
        },
    },
}
