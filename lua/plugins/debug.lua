-- Debug plugins: nvim-dap ecosystem

return {
    -- DAP - Debug Adapter Protocol
    {
        "mfussenegger/nvim-dap",
        cond = function() return vim.fn.executable("gdb") == 1 or vim.fn.executable("codelldb") == 1 end,
        dependencies = {
            "nvim-neotest/nvim-nio",
            "theHamsta/nvim-dap-virtual-text",
            "mfussenegger/nvim-dap-python",
        },
    },

    -- DAP UI
    {
        "rcarriga/nvim-dap-ui",
        cond = function() return vim.fn.executable("gdb") == 1 or vim.fn.executable("codelldb") == 1 end,
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
    },

    -- Neotest - Test runner
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "alfaix/neotest-gtest",
        },
    },

    -- CTest telescope integration
    { "SGauvin/ctest-telescope.nvim" },

    -- CMake tools
    { "Civitasv/cmake-tools.nvim" },
}
