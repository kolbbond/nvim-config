-- Fugitive keymaps
vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git status" })
vim.keymap.set("n", "<leader>gd", ":Gdiffsplit<CR>", { desc = "Git diff split" })
vim.keymap.set("n", "<leader>gb", ":Git blame<CR>", { desc = "Git blame" })
vim.keymap.set("n", "<leader>gl", ":Git log --oneline<CR>", { desc = "Git log" })
vim.keymap.set("n", "<leader>gL", ":Git log -p %<CR>", { desc = "Git log current file" })
vim.keymap.set("n", "<leader>gc", ":Git commit<CR>", { desc = "Git commit" })
vim.keymap.set("n", "<leader>gp", ":Git push<CR>", { desc = "Git push" })
vim.keymap.set("n", "<leader>gP", ":Git pull<CR>", { desc = "Git pull" })
vim.keymap.set("n", "<leader>gf", ":Git fetch<CR>", { desc = "Git fetch" })

-- Merge conflict resolution
vim.keymap.set("n", "<leader>gh", ":diffget //2<CR>", { desc = "Get from left (HEAD)" })
vim.keymap.set("n", "<leader>gj", ":diffget //3<CR>", { desc = "Get from right (incoming)" })
