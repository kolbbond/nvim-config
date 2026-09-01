local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()

-- <leader>a* is the claude namespace (lua/plugins/claude.lua); harpoon lives on h
vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon: add file" })

-- open quick menu
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
    { desc = "Harpoon: quick menu" })

-- quick file select
vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end, { desc = "Harpoon: file 1" })
vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end, { desc = "Harpoon: file 2" })
vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end, { desc = "Harpoon: file 3" })
vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end, { desc = "Harpoon: file 4" })

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end, { desc = "Harpoon: prev" })
vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end, { desc = "Harpoon: next" })
