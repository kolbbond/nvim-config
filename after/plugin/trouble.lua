local tb = require('trouble').setup({
    opts = {},
    -- cmd = "Trouble",
});

-- set trouble keymaps
vim.keymap.set("n", "<leader>tt", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle Trouble diagnostics" });
vim.keymap.set("n", "<leader>tT", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>");
vim.keymap.set("n", "<leader>ts", "<cmd>Trouble symbols toggle focus=false<cr>");
vim.keymap.set("n", "<leader>tl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>");
vim.keymap.set("n", "<leader>tL", "<cmd>Trouble loclist toggle<cr>");
vim.keymap.set("n", "<leader>tq", "<cmd>Trouble qflist toggle<cr>");

local actions = require("telescope.actions")
local open_with_trouble = require("trouble.sources.telescope").open

-- Use this to add more results without clearing the trouble list
local add_to_trouble = require("trouble.sources.telescope").add

local telescope = require("telescope")

telescope.setup({
    defaults = {
        mappings = {
            i = { ["<c-t>"] = open_with_trouble },
            n = { ["<c-t>"] = open_with_trouble },
        },
    },
})

-- workspace project diagnostics
vim.api.nvim_set_keymap('n', '<leader>pd', '', {
    noremap = true,
    callback = function()
        --for _, client in ipairs(vim.lsp.buf_get_clients()) do
        for _, client in ipairs(vim.lsp.get_active_clients()) do
            require("workspace-diagnostics").populate_workspace_diagnostics(client, 0)
        end
    end
})
