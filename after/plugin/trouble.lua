local tb = require('trouble').setup({
    opts = {},
   -- cmd = "Trouble",
});

-- set trouble keymaps
vim.keymap.set("n", "<leader>tt", "<cmd>Trouble diagnostics toggle<cr>",{desc="Toggle Trouble diagnostics"});
vim.keymap.set("n", "<leader>tT", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>");
vim.keymap.set("n", "<leader>ts", "<cmd>Trouble symbols toggle focus=false<cr>");
vim.keymap.set("n", "<leader>tl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>");
vim.keymap.set("n", "<leader>tL", "<cmd>Trouble loclist toggle<cr>");
vim.keymap.set("n", "<leader>tq", "<cmd>Trouble qflist toggle<cr>");

