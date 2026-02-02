-- REPL plugins: vim-slime, iron.nvim, nvim-matlab, molten, jupynium

return {
    -- MATLAB (custom fork)
    { "kolbbond/nvim-matlab" },

    -- Iron - REPL for Python/Octave
    { "Vigemus/iron.nvim" },

    -- Slime - Send code to tmux panes
    { "jpalardy/vim-slime" },

    -- Molten - Jupyter-style code execution in Neovim
    {
        "benlubas/molten-nvim",
        build = ":UpdateRemotePlugins",
        dependencies = {
            "3rd/image.nvim",
        },
    },

    -- Image rendering (for molten output)
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
    },
}
