-- Tools plugins: fugitive, undotree, asyncrun, todo-comments, etc.

return {
    -- Todo comments highlighting
    { "folke/todo-comments.nvim" },

    -- Undotree - Visualize undo history
    { "mbbill/undotree" },

    -- Fugitive - Git integration
    { "tpope/vim-fugitive" },

    -- AsyncRun - Non-blocking command execution
    { "skywind3000/asyncrun.vim" },

    -- Suda - Write with elevated permissions
    { "lambdalisue/suda.vim" },

    -- VimBeGood - Practice games (custom fork)
    { "kolbbond/vim-be-good" },

    -- nvim-surround - Add/change/delete surroundings
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        opts = {},
    },
}
